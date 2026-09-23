// lib/db-name.mjs — the one MongoDB database-name derivation, shared by the app and the pipeline (TEMPLATE-OWNED).
//
// Decision D35: a MongoDB repo gets a database per run (`run_<slug>`) and, where it declares
// `database.mongodb.previews: "branch"`, a database per preview (`preview_<git branch>`), all on
// the one cluster it already uses. The names are derived, never stored: the app derives its
// preview database from the branch Vercel deploys, the scripts derive the same name from the
// branch or the run slug, and this file is the only place the rule lives — so the two cannot
// disagree. Dependency-free on purpose: the app imports it (server-side), the scripts run it with
// `node`, and neither needs anything installed.
//
// The rule (MongoDB: at most 63 bytes, no `/\. "$*<>:|?`, case-insensitive uniqueness):
//   lower-case; every run of characters outside [a-z0-9_] becomes one `_`; leading and trailing
//   `_` dropped; `<prefix>_` in front. A name longer than 63 keeps its first 54 characters and
//   gains `_` + an 8-hex FNV-1a hash of the whole normalised body, so two long branches that
//   share a prefix still get two databases.
//     runDbName("csv-export")                → run_csv_export
//     previewDbName("claude/csv-export")     → preview_claude_csv_export
//     previewDbName("Feature/ÜBER.fix")      → preview_feature_ber_fix
//
// The app side — the one line a repo changes (its connection code), gated by one variable:
//   import { databaseName } from "<path to>/.icm/scripts/lib/db-name.mjs";
//   mongoose.connect(uri, { dbName: databaseName(process.env, "MONGODB_DATABASE_NAME") });
// databaseName() returns preview_<VERCEL_GIT_COMMIT_REF> when VERCEL_ENV is "preview" AND
// MONGODB_PREVIEW_PER_BRANCH is "1" (set once, on the Preview target — Vercel's system
// environment variables must be exposed); otherwise the value of the name variable, exactly as
// before. Unsetting the flag is the whole revert. A repo that cannot import across its package
// boundary copies this file verbatim and keeps it byte-identical — the examples above are its test.
//
// CLI (what the scripts and workflows call):
//   node .icm/scripts/lib/db-name.mjs run <slug>        → run_<slug>
//   node .icm/scripts/lib/db-name.mjs preview <branch>  → preview_<branch>
//   node .icm/scripts/lib/db-name.mjs preview --stdin   → one name per input line (a branch list)

export const MAX_DB_NAME = 63;
export const PREVIEW_FLAG = "MONGODB_PREVIEW_PER_BRANCH";

export function normalise(raw) {
  return String(raw ?? "")
    .toLowerCase()
    .replace(/[^a-z0-9_]+/g, "_")
    .replace(/_+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function fnv1a(s) {
  let h = 0x811c9dc5;
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return h.toString(16).padStart(8, "0");
}

export function pipelineDbName(prefix, raw) {
  const body = normalise(raw);
  if (!body) throw new Error(`db-name: '${raw}' leaves nothing after normalising`);
  const name = `${prefix}_${body}`;
  return name.length <= MAX_DB_NAME ? name : `${name.slice(0, MAX_DB_NAME - 9)}_${fnv1a(body)}`;
}

export const runDbName = (slug) => pipelineDbName("run", slug);
export const previewDbName = (branch) => pipelineDbName("preview", branch);

export function databaseName(env = process.env, nameEnv = "MONGODB_DATABASE_NAME") {
  if (env.VERCEL_ENV === "preview" && env[PREVIEW_FLAG] === "1" && env.VERCEL_GIT_COMMIT_REF) {
    return previewDbName(env.VERCEL_GIT_COMMIT_REF);
  }
  return env[nameEnv];
}

// --- CLI — only when run directly, never on import --------------------------------------------------
if (typeof process !== "undefined" && /db-name\.mjs$/.test(process.argv?.[1] ?? "")) {
  const [kind, arg] = process.argv.slice(2);
  const fn = { run: runDbName, preview: previewDbName }[kind];
  if (!fn || !arg) {
    process.stderr.write("usage: db-name.mjs run <slug> | preview <branch> | preview --stdin\n");
    process.exit(2);
  }
  if (arg === "--stdin") {
    let input = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (c) => (input += c));
    process.stdin.on("end", () => {
      for (const line of input.split("\n")) if (line.trim()) process.stdout.write(`${fn(line.trim())}\t${line.trim()}\n`);
    });
  } else {
    process.stdout.write(`${fn(arg)}\n`);
  }
}
