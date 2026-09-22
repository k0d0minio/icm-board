# Modelo de acordo — português

*Referência de nível 3 para [`05_agreement`](../stages/05_agreement/CONTEXT.md). Prática da
casa em palavras simples, segundo [`terms.md`](../../../_system/knowledge/terms.md);
`[LAWYER]` marca cada espaço que se pareça com redação jurídica — isto não é
aconselhamento, e nada de jurídico é inventado além do que `terms.md` já estabelece.
Convertido em DOCX por `render-deal.sh`, colocado na pasta Drive do cliente, assinado via
Google eSignature. A identidade vem de `DEAL.md` e da conversão; nenhuma morada nem tarifa
aqui.*

```markdown
# Acordo — <nome do projeto>

- language: pt
- tier: foundation | full-build | partnership
- shape: one-off | one-off + support | retainer | partnership
- agreed: <EUR>
- recurring: <EUR/mês | none>
- signed: pending | <AAAA-MM-DD>
- drive: <ligação>
- proposal: 04-proposal.md (<data>)

## 1. Partes

<Empresa ou nome do cliente>, <a pessoa que assina e a sua função> — «você».
Jamie Nisbet, engenheiro de software e consultor de IA, Mafra, Portugal — «eu».

## 2. O que é construído

O trabalho descrito em *O que recebe* na proposta de <data>, no nível **<tier>**, e nada do
que essa proposta lista em *Não incluído*. A proposta faz parte deste acordo; onde os dois
divergirem, prevalece o acordo.

## 3. Preço e calendário de pagamento

**<agreed> €**, preço fixo. 50 % na assinatura, faturados nessa altura; 50 % na entrega.
<Ou o desvio do orçamento, dito com clareza.> Faturas via Stripe, pagáveis à receção.
<Se um diagnóstico foi pago: «Os <n> € do diagnóstico de <data> são deduzidos da primeira
fatura.»>

## 4. O que é seu, e onde vive

<Propriedade do cliente: «O código, os conteúdos, o domínio e as contas de alojamento
estão em seu nome desde o início; tenho acesso enquanto o trabalho decorre e durante o
período de suporte abaixo.»>
<Alojado por Jamie: «O código e os conteúdos são seus. As contas de alojamento, base de
dados, e-mail e domínio são minhas e são-lhe refaturadas mensalmente ao preço de custo,
com um limite de <n> €/mês durante o desenvolvimento; pode transferi-las para as suas
próprias contas a qualquer momento e eu ajudo.»>

## 5. Alojamento e suporte após a entrega

<nenhum: «Uma landing page não tem custo recorrente nem linha de suporte; os defeitos
dentro do âmbito são corrigidos em qualquer caso.»>
<básico: «**<recurring> €/mês** para alojamento e suporte básico — quando a aplicação está
em baixo ou um fluxo está partido, eu corrijo. Requer a página de contingência e o
rastreio de erros, ambos incluídos na construção. Não inclui novas funcionalidades nem
alterações de conteúdo. Qualquer um de nós pode terminá-lo com um mês de pré-aviso.»>

## 6. Revisões

Estão incluídas duas rondas de revisões sobre o que foi construído. A partir daí, as
alterações são orçamentadas. O que está no âmbito escrito e simplesmente errado é corrigido
em qualquer caso.

## 7. Prazos

As estimativas contam a partir do dia em que o sinal é pago e os elementos da lista de
integração são recebidos — não a partir da assinatura. <A estimativa: «<n> semanas até à
entrega.»>

## 8. Terminar

Qualquer um de nós pode terminar este acordo por escrito. O trabalho feito e faturado
fica pago; o trabalho feito e ainda não faturado é faturado proporcionalmente; fica com o
que foi entregue.

## 9. Termos separados [LAWYER]

<apenas parceria: «Os termos de comissão / partilha de receitas / participação estão
fixados no acordo separado de <data> e não são aqui repetidos.» — nunca uma percentagem
nesta página.>
<qualquer etiqueta [LAWYER] do orçamento, palavra por palavra, marcada «a formalizar
devidamente».>

## 10. Assinaturas

<Nome do cliente, função, data>                     Jamie Nisbet, data
(assinado eletronicamente via Google eSignature)
```
