# Prompt v3.3: memória aos poucos

Usado pelo gerador do Fuxico no modo padrão: **um pedido por bloco**, em ordem. Cada pedido recebe a memória até o bloco anterior e o texto do bloco novo, e devolve só a memória deste bloco, no formato de [formato-memoria.md](../docs/formato-memoria.md#o-que-a-ia-devolve-por-bloco).

Diferenças em relação ao v2 ([livro inteiro](memoria-livro-inteiro.md)):
- A IA nunca vê o texto além do bloco atual, então o spoiler só pode vir do que ela "sabe" do livro.
- Os personagens chegam como uma lista única; a IA devolve só quem é novo ou tem novidade.
- O `resumo_ate_aqui` sobe para 150 palavras.
- Regra explícita sobre lugar de morte e de enterro, o erro que sobrou no v2.

Mudanças do v3.1, depois do [teste com *Dom Casmurro*](../docs/teste-dom-casmurro.md#rodada-3-prompt-v3-aos-poucos), em que 22 dos 27 blocos precisaram de correção:
- **Fichas condensadas:** 33 das 43 falhas foram fichas de protagonistas com 31 a 36 palavras, porque a IA só acrescentava. Agora a regra manda reescrever a ficha inteira, condensando o que já se sabia.
- **Margem nos resumos:** o `resumo_ate_aqui` ficava em média com 144 palavras e passou de 150 três vezes. Agora a regra pede para mirar em cerca de 130.
- **Quem entra na lista:** a lista chegou a 47 pessoas, 27 delas figurantes de uma cena só. Agora só entra quem tem nome no texto ou tem papel no bloco; grupos e figurantes, não.
- **Sem nome e outras grafias:** quem não tem nome é chamado como o texto o chama, com a grafia do texto, o que evita falsos alertas como "pai" por "pae". Uma grafia diferente de alguém que já está na lista vira apelido.
- **Corte da lista:** acima de 30 pessoas, os mais antigos continuam no pedido, só sem ficha. Assim quem volta à história não é recriado como novo.
- **Correção:** um pedido só para vários campos, e a IA pode manter um nome que está mesmo no texto.

Mudança do v3.2 (ainda não testada):
- **Fios soltos:** um campo novo, `fios_soltos`, com até 3 frases curtas sobre o que está em aberto na história até o fim do bloco (promessas, dúvidas, conflitos sem resposta). Alimenta a seção "Fios soltos" do [O que rolou?](../docs/funcoes.md#o-que-rolou). A IA recebe os fios do bloco anterior e devolve a lista inteira atualizada: tira o que se resolveu, mantém o que segue aberto e acrescenta o que surgiu. Os fios passam pela mesma checagem de nomes dos resumos.

Mudança do v3.3 (ainda não testada):
- **Lugares:** a lista passa a ter pessoas e lugares, com um campo `tipo` ("pessoa" ou "lugar") em quem é novo. Alimenta o tipo mostrado no [Quem é esse?](../docs/funcoes.md#quem-é-esse) e a seção "Onde" do [Quem tá na cena?](../docs/funcoes.md#quem-tá-na-cena). Só entram lugares com nome no texto ou onde a cena acontece e que voltam a aparecer; os citados de passagem, não. `presentes` aceita até 10 pessoas e 3 lugares.

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
- "resumo_ate_aqui": a história TODA, do começo do livro até o fim deste bloco, em cerca de 130 palavras e nunca mais de 150. Parta do resumo anterior: mantenha o essencial, condense o começo e acrescente o que é novo. Não é o resumo do bloco.
- "resumo_do_bloco": só o que acontece neste bloco, em cerca de 40 palavras e nunca mais de 50. O acontecimento principal do bloco tem de estar aqui.
- "fios_soltos": o que está em aberto na história até o fim deste bloco, em no máximo 3 itens de até 15 palavras cada. Parta dos fios anteriores: tire o que o texto já resolveu, mantenha o que segue em aberto e acrescente o que surgiu neste bloco, ficando com os mais importantes.
  - Só o que o texto deixou em aberto: uma promessa, uma dúvida, um plano, um conflito sem resposta. Não invente suspense que o texto não criou.
  - Escreva como está agora ("ainda não sabe", "prometeu", "continua sem resposta"), sem sugerir se, como ou quando vai se resolver.
  - Se não houver nada em aberto, devolva uma lista vazia.
- "presentes": os "id" de quem e do que importa neste bloco, em ordem de importância: no máximo 10 pessoas e 3 lugares.
- "personagens_novos_ou_atualizados": pessoas e lugares. Só quem apareceu pela primeira vez ou de quem o leitor descobriu algo novo neste bloco. Quem não mudou não entra.
  - Quem entra na lista: pessoas com nome no texto, ou sem nome mas com papel no bloco (que falam, agem ou voltam a aparecer). Grupos ("os colegas"), multidões e figurantes de uma frase não entram.
  - Quais lugares entram: lugares com nome no texto (uma cidade, um bairro, uma rua, uma casa ou fazenda com nome) ou o lugar onde uma cena acontece e que volta a aparecer. Lugares citados de passagem não entram.
  - "tipo": "pessoa" ou "lugar". Só para quem é novo; quem já está na lista mantém o tipo.
  - Para quem já está na lista, use o mesmo "id" e não repita o "nome". Se a pessoa aparece com outra grafia ou outro nome, continua sendo ela: use o "id" existente e ponha a forma nova em "apelidos_novos".
  - Para quem é novo, crie um "id" curto, em minúsculas, sem acentos, com hífen no lugar de espaço (por exemplo "jose-dias"), e informe o "nome" exatamente como aparece no texto, com a grafia do texto. Se a pessoa não tem nome, o "nome" é a forma como o texto a chama (por exemplo "o pae de Bentinho").
  - "apelidos_novos": só apelidos e outras formas de chamar a pessoa que surgiram neste bloco, e só quando o texto deixa claro que são a mesma pessoa. Sobrenome não é apelido.
  - "quem_e_ate_aqui": a ficha completa até este bloco, em até 30 palavras. Para um lugar: o que é e o que aconteceu ali até aqui. Reescreva a ficha inteira juntando o que se sabia antes e o que é novo, e condense: fique com o que identifica a pessoa e o essencial do que ela fez. Não vá só acrescentando.

FORMATO
Responda só com um objeto JSON válido, sem nada antes ou depois. Cada texto em uma linha só.

{
  "bloco": N,
  "resumo_ate_aqui": "...",
  "resumo_do_bloco": "...",
  "fios_soltos": ["...", "..."],
  "presentes": ["id", "..."],
  "personagens_novos_ou_atualizados": [
    { "id": "...", "nome": "só se for novo", "tipo": "pessoa ou lugar, só se for novo", "apelidos_novos": ["..."], "quem_e_ate_aqui": "..." }
  ]
}

ANTES DE RESPONDER, CONFIRA
- O resumo_ate_aqui cobre desde o começo do livro e tem no máximo 150 palavras? Conte.
- O resumo_do_bloco tem no máximo 50 palavras e traz o acontecimento principal? Conte.
- Cada quem_e_ate_aqui tem no máximo 30 palavras? Conte, sobretudo nas fichas dos protagonistas.
- Os fios_soltos são no máximo 3, cada um com no máximo 15 palavras, e nenhum dá pista do que vai acontecer?
- Cada fato está no texto deste bloco ou na memória anterior?
- Cada "id" de personagem já existente foi reaproveitado, sem criar duplicata?
- Cada pessoa ou lugar novo tem "tipo"? Os presentes têm no máximo 10 pessoas e 3 lugares?
- Escreva em português do Brasil atual, em frases simples, sem copiar frases do livro, mantendo os nomes de pessoas como aparecem no texto.
```

## Pedido (um por bloco)

```
BLOCO {{n}} de {{total}} (capítulos {{capitulo_inicial}} a {{capitulo_final}})

MEMÓRIA ATÉ O BLOCO ANTERIOR
Resumo até aqui: {{resumo_ate_aqui_anterior}}

Fios soltos até aqui:
{{fios_soltos_anteriores}}

Personagens e lugares conhecidos:
{{personagens_conhecidos}}

TEXTO DO BLOCO {{n}}:
{{texto_do_bloco}}
```

### Como o gerador preenche

- `{{resumo_ate_aqui_anterior}}`: o `resumo_ate_aqui` do bloco anterior. No bloco 1: `(início do livro)`.
- `{{fios_soltos_anteriores}}`: os `fios_soltos` do bloco anterior, um por linha, começando com "- ". No bloco 1, ou se a lista estiver vazia: `(nenhum)`.
- `{{personagens_conhecidos}}`: uma linha por pessoa ou lugar da lista única, no formato abaixo, com o tipo. No bloco 1: `(nenhum ainda)`.

```
- jose-dias | José Dias | pessoa | apelidos: — | Agregado da casa há muitos anos, ...
- capitu | Capitú | pessoa | apelidos: Capitolina | Vizinha de Bentinho, ...
- matacavalos | Matacavalos | lugar | apelidos: — | Rua onde fica a casa da família de Bentinho, ...
```

  Se a lista passar de 30 pessoas e lugares, os 30 com `desde_bloco` ou ficha mais recentes vão com a ficha. Os outros vão no fim, só com `id`, nome e apelidos, para a IA reconhecer quem volta e reaproveitar o `id`:

```
Outros personagens e lugares (sem ficha):
- joao-da-costa | doutor João da Costa | pessoa | apelidos: —
```

### Pedido de correção (só quando falha a checagem)

Quando um campo passa do limite ou cita um nome que não está no texto até aqui, o gerador manda, na mesma conversa, uma linha por problema:

```
A resposta precisa de ajuste:
{{problemas}}
Reescreva só esses campos, mantendo as regras, e responda com o objeto JSON completo de novo. Se um nome apontado estiver mesmo no texto deste bloco, mantenha-o, escrito exatamente como no texto.
```

Cada linha de `{{problemas}}` é `- o campo "{{campo}}" {{problema}}`. Exemplos de `{{problema}}`: `tem 163 palavras; o limite é 150`, `tem 4 itens; o limite é 3`, `cita "Ezequiel", que ainda não apareceu no texto`.

### Tamanho de cada pedido

Instruções (cerca de 1.100 tokens) + memória anterior (até 1.600, com os fios soltos) + bloco de 2 mil palavras (cerca de 3.500) ≈ **6 mil tokens de entrada** e até 1 mil de saída. Um romance de 27 blocos dá cerca de 160 mil tokens de entrada no total, mais do que no modo livro inteiro, porque a memória e as instruções se repetem; com cache das instruções, o custo cai.
