# The project register — moved to the template

The register's shape and rules now live in the template, so a repo carries them with no
icm-board in reach (D45): **[`template/icm-pipeline/_shared/register.md`](../template/icm-pipeline/_shared/register.md)**
— `T`, synced to every pipeline repo as `.icm/_shared/register.md`. The register itself,
`.icm/project.md`, is `P` in the MANIFEST: seeded once as the unfilled stub
[`template/icm-pipeline/project.md`](../template/icm-pipeline/project.md) (`> Last run:
never`), then the repo's forever.

This file stays only so existing links resolve. One home per fact — never restate the shape
here. icm-board's own [`.icm/project.md`](../../.icm/project.md) follows the same shape and
keeps whatever extra sections it already carries.
