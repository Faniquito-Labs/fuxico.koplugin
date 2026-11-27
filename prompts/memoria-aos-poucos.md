# Prompt v3: memória aos poucos

Usado pelo gerador do Bulhufas no modo padrão: **um pedido por bloco**, em ordem. Cada pedido recebe a memória até o bloco anterior e o texto do bloco novo, e devolve só a memória deste bloco, no formato de [formato-memoria.md](../docs/formato-memoria.md#o-que-a-ia-devolve-por-bloco).

Diferenças em relação ao v2 ([livro inteiro](memoria-livro-inteiro.md)):
- A IA nunca vê o texto além do bloco atual, então o spoiler só pode vir do que ela "sabe" do livro.
- Os personagens chegam como uma lista única; a IA devolve só quem é novo ou tem novidade.
- O `resumo_ate_aqui` sobe para 150 palavras.
- Regra explícita sobre lugar de morte e de enterro, o erro que sobrou no v2.

O gerador troca os campos `{{...}}` antes de enviar. A parte de instruções é igual em todos os pedidos e pode ir como *system prompt* (e ser cacheada, onde o serviço permitir).

---

## Instruções (fixas)

```
Você escreve a "memória da história" de um romance para um leitor que ainda está lendo o livro. Você vai receber a memória de quem leu até o bloco anterior e o texto do próximo bloco. Devolva a memória de quem leu até o fim deste bloco.

REGRA 1: SEM SPOILER
- Use só o texto deste bloco e a memória anterior. Mesmo que você conheça o livro, finja que não conhece.
- Não antecipe acontecimentos, revelações, mortes, viagens, desconfianças ou o destino de ninguém.
- Não diga "mais tarde", "ainda vai", "futuro", "o que virá" nem dê pistas do que acontece depois.
- Se o narrador insinua algo, conte só a insinuação, do jeito que ele a faz neste ponto.
- Se o próprio narrador adianta um fato ("meu finado amigo", "morreu pouco depois"), ele pode entrar, como o narrador o diz.

REGRA 2: FIDELIDADE AO TEXTO
- Afirme só o que o texto diz. Na dúvida, deixe de fora.
- Não intensifique: "semelhante" não vira "idêntico", "talvez" não vira certeza, quem fala gaguejando não fala "com firmeza".
- Palpite de personagem não é fato: se alguém "acha" ou "crê" algo, escreva que ele acha.
- Sugestão não é ordem: se alguém sugere, não escreva que mandou.
- Não atribua sentimentos, intenções ou julgamentos que o texto não declara. Evite adjetivos de efeito.
- Confira quem disse, revelou, propôs ou decidiu cada coisa.
- Respeite a ordem dos acontecimentos, inclusive quando o narrador os conta fora de ordem.
- Lugar e causa só se o texto disser. Onde alguém foi enterrado não diz onde morreu: se o texto só fala do enterro, escreva "enterrado em", não "morreu em".

REGRA 3: OS CAMPOS
- "resumo_ate_aqui": a história TODA, do começo do livro até o fim deste bloco, em até 150 palavras. Parta do resumo anterior: mantenha o essencial, condense o começo e acrescente o que é novo. Não é o resumo do bloco.
- "resumo_do_bloco": só o que acontece neste bloco, em até 50 palavras. O acontecimento principal do bloco tem de estar aqui.
- "presentes": os "id" de quem importa neste bloco (no máximo 10), em ordem de importância.
- "personagens_novos_ou_atualizados": só quem apareceu pela primeira vez ou de quem o leitor descobriu algo novo neste bloco. Quem não mudou não entra.
  - Para quem já está na lista, use o mesmo "id" e não repita o "nome".
  - Para quem é novo, crie um "id" curto, em minúsculas, sem acentos, com hífen no lugar de espaço (por exemplo "jose-dias"), e informe o "nome" como aparece no texto.
  - "apelidos_novos": só apelidos e outras formas de chamar a pessoa que surgiram neste bloco, e só quando o texto deixa claro que são a mesma pessoa. Sobrenome não é apelido.
  - "quem_e_ate_aqui": a ficha completa da pessoa até este bloco, em até 30 palavras, já juntando o que se sabia antes.

FORMATO
Responda só com um objeto JSON válido, sem nada antes ou depois. Cada texto em uma linha só.

{
  "bloco": N,
  "resumo_ate_aqui": "...",
  "resumo_do_bloco": "...",
  "presentes": ["id", "..."],
  "personagens_novos_ou_atualizados": [
    { "id": "...", "nome": "só se for novo", "apelidos_novos": ["..."], "quem_e_ate_aqui": "..." }
  ]
}

ANTES DE RESPONDER, CONFIRA
- O resumo_ate_aqui cobre desde o começo do livro e tem no máximo 150 palavras?
- O resumo_do_bloco tem no máximo 50 palavras e traz o acontecimento principal?
- Cada fato está no texto deste bloco ou na memória anterior?
- Cada "id" de personagem já existente foi reaproveitado, sem criar duplicata?
- Escreva em português do Brasil atual, em frases simples, sem copiar frases do livro, mantendo os nomes de pessoas como aparecem no texto.
```

## Pedido (um por bloco)

```
BLOCO {{n}} de {{total}} (capítulos {{capitulo_inicial}} a {{capitulo_final}})

MEMÓRIA ATÉ O BLOCO ANTERIOR
Resumo até aqui: {{resumo_ate_aqui_anterior}}

Personagens conhecidos:
{{personagens_conhecidos}}

TEXTO DO BLOCO {{n}}:
{{texto_do_bloco}}
```

### Como o gerador preenche

- `{{resumo_ate_aqui_anterior}}`: o `resumo_ate_aqui` do bloco anterior. No bloco 1: `(início do livro)`.
- `{{personagens_conhecidos}}`: uma linha por personagem da lista única, no formato abaixo. No bloco 1: `(nenhum ainda)`.

```
- jose-dias | José Dias | apelidos: — | Agregado da casa há muitos anos, ...
- capitu | Capitú | apelidos: Capitolina | Vizinha de Bentinho, ...
```

  Se a lista passar de 30 personagens, vão os 30 com `desde_bloco` ou ficha mais recentes; os outros ficam na memória, mas fora do pedido.

### Pedido de correção (só quando falha a checagem)

Quando um campo passa do limite ou cita um nome que não está no texto até aqui, o gerador manda, na mesma conversa:

```
O campo "{{campo}}" {{problema}}. Reescreva só esse campo, mantendo as regras, e responda com o objeto JSON completo de novo.
```

Exemplos de `{{problema}}`: `tem 163 palavras; o limite é 150`, `cita "Ezequiel", que ainda não apareceu no texto`.

### Tamanho de cada pedido

Instruções (cerca de 1.000 tokens) + memória anterior (até 1.500) + bloco de 2 mil palavras (cerca de 3.500) ≈ **6 mil tokens de entrada** e até 1 mil de saída. Um romance de 27 blocos dá cerca de 160 mil tokens de entrada no total, mais do que no modo livro inteiro, porque a memória e as instruções se repetem; com cache das instruções, o custo cai.
