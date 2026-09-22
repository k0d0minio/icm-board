# Modèle d'accord — français

*Référence de niveau 3 pour [`05_agreement`](../stages/05_agreement/CONTEXT.md). Pratique
maison en mots simples, d'après [`terms.md`](../../../_system/knowledge/terms.md) ;
`[LAWYER]` marque chaque emplacement qui ressemble à de la rédaction juridique — ceci n'est
pas un conseil, et rien de juridique n'est inventé au-delà de ce que `terms.md` établit déjà.
Rendu en DOCX par `render-deal.sh`, déposé dans le dossier Drive du client, signé via Google
eSignature. L'identité vient de `DEAL.md` et du rendu ; aucune adresse ni aucun tarif ici.*

```markdown
# Accord — <nom du projet>

- language: fr
- tier: foundation | full-build | partnership
- shape: one-off | one-off + support | retainer | partnership
- agreed: <EUR>
- recurring: <EUR/mois | none>
- signed: pending | <AAAA-MM-JJ>
- drive: <lien>
- proposal: 04-proposal.md (<date>)

## 1. Parties

<Société ou nom du client>, <la personne qui signe et son rôle> — « vous ».
Jamie Nisbet, ingénieur logiciel et consultant IA, Mafra, Portugal — « je ».

## 2. Ce qui est construit

Le travail décrit sous *Ce que vous obtenez* dans la proposition du <date>, au niveau
**<tier>**, et rien de ce que cette proposition liste sous *Non compris*. La proposition
fait partie du présent accord ; en cas de divergence, l'accord prévaut.

## 3. Prix et échéancier

**<agreed> €**, forfait. 50 % à la signature, facturés alors ; 50 % à la remise.
<Ou l'écart du devis, dit simplement.> Factures via Stripe, payables à réception.
<Si un diagnostic a été payé : « Les <n> € du diagnostic du <date> sont déduits de la
première facture. »>

## 4. Ce qui est à vous, et où cela vit

<Propriété client : « Le code, les contenus, le domaine et les comptes d'hébergement sont à
votre nom dès le départ ; j'y ai accès pendant le travail et pendant la période de support
ci-dessous. »>
<Hébergé par Jamie : « Le code et les contenus sont à vous. Les comptes d'hébergement, de
base de données, d'e-mail et de domaine sont les miens et vous sont refacturés chaque mois
au prix coûtant, plafonnés à <n> €/mois pendant le développement ; vous pouvez les
transférer sur vos propres comptes à tout moment et je vous y aiderai. »>

## 5. Hébergement et support après la remise

<aucun : « Une page d'atterrissage n'a aucun coût récurrent et aucune ligne de support ;
les défauts dans le périmètre sont corrigés quoi qu'il arrive. »>
<basique : « **<recurring> €/mois** pour l'hébergement et le support de base — quand
l'application est en panne ou qu'un parcours est cassé, je le répare. Cela suppose la page
de secours et le suivi d'erreurs, tous deux compris dans la construction. Cela ne comprend
ni nouvelles fonctionnalités ni changements de contenu. Chacun peut y mettre fin avec un
mois de préavis. »>

## 6. Révisions

Deux tours de révisions sur ce qui a été construit sont compris. Au-delà, les changements
sont chiffrés. Ce qui est dans le périmètre écrit et simplement erroné est corrigé quoi
qu'il arrive.

## 7. Calendrier

Les estimations courent à partir du jour où l'acompte est payé et où les éléments de la
liste d'intégration sont reçus — pas à partir de la signature. <L'estimation : « <n>
semaines jusqu'à la remise. »>

## 8. Y mettre fin

Chacun peut mettre fin au présent accord par écrit. Le travail fait et facturé reste payé ;
le travail fait et non encore facturé est facturé au prorata ; vous gardez ce qui a été
livré.

## 9. Termes séparés [LAWYER]

<partenariat uniquement : « Les termes de commission / partage de revenus / participation
sont fixés dans l'accord séparé du <date> et ne sont pas repris ici. » — jamais un
pourcentage sur cette page.>
<toute balise [LAWYER] du devis, mot pour mot, marquée « à formaliser correctement ».>

## 10. Signatures

<Nom du client, rôle, date>                     Jamie Nisbet, date
(signé électroniquement via Google eSignature)
```
