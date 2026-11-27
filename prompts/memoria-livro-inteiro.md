Você vai criar a "memória da história" de um romance, para um leitor que ainda está lendo o livro.

Abaixo está o livro inteiro, dividido em blocos numerados ("===== BLOCO N ====="). Para CADA bloco, escreva a memória de quem leu o livro só até o fim daquele bloco.

REGRA 1: SEM SPOILER
- A memória do bloco N só pode usar o que está escrito nos blocos 1 a N.
- Mesmo que você conheça este livro, finja que não conhece. Não antecipe acontecimentos, revelações, mortes, viagens, desconfianças ou o destino de ninguém.
- Não cite personagens antes do bloco em que eles aparecem no texto.
- Não diga "mais tarde", "ainda vai", "futuro", "o que virá" nem dê pistas do que acontece depois.
- Se o narrador insinua algo, conte só a insinuação, do jeito que ele a faz naquele ponto.
- Se o próprio narrador adianta um fato ("meu finado amigo", "morreu pouco depois"), ele pode entrar, mas só a partir do bloco em que o narrador o diz.

REGRA 2: FIDELIDADE AO TEXTO
- Afirme só o que o texto diz. Na dúvida, deixe de fora.
- Não intensifique: se o texto diz "semelhante", não escreva "idêntico"; se o personagem fala gaguejando, não escreva "com firmeza"; se o texto diz "talvez", não escreva como certeza.
- Não atribua sentimentos, intenções ou julgamentos que o texto não declara. Evite adjetivos de efeito ("avassalador", "devorador", "intensa sedução").
- Atribua cada fala, ideia e decisão a quem a teve no texto. Confira quem propôs, quem revelou, quem aceitou.
- Respeite a ordem dos acontecimentos: antes e depois importam (quem morreu antes de quem, quem chegou antes de quem).
- Não invente lugar, data ou causa que o texto não dá (por exemplo, "morreu em tal cidade" quando o texto só diz onde foi enterrado).

REGRA 3: O QUE CADA CAMPO É
- "resumo_ate_aqui": a história TODA, do começo do livro até o fim do bloco N, em até 120 palavras. NÃO é o resumo do bloco. A cada bloco, reescreva o resumo inteiro, condensando o início para dar lugar ao que é novo. Quem ler só este campo precisa saber o essencial de tudo o que já aconteceu.
- "resumo_do_bloco": o que acontece só neste bloco, em até 50 palavras. O acontecimento principal do bloco tem de estar aqui.
- "personagens": as fichas de quem importa até este ponto (no máximo 10).
  - Mantenha a ficha de quem já apareceu e continua importante para a história, mesmo que não apareça neste bloco.
  - Inclua quem tem papel central no bloco.
  - "apelidos": junte um apelido à pessoa só quando o texto deixar claro que é a mesma pessoa. Depois de juntado, o apelido continua na ficha em todos os blocos seguintes.
  - "quem_e_ate_aqui": quem é a pessoa e o que o leitor sabe dela até este bloco, em até 30 palavras.

FORMATO
Responda só com JSON válido: uma lista de objetos, um por bloco, em ordem. Nada de texto fora do JSON, a não ser a linha "CONTINUA NO BLOCO N" explicada abaixo. Cada texto fica numa linha só, sem quebras de linha dentro das aspas.

[
  {
    "bloco": 1,
    "resumo_ate_aqui": "...",
    "resumo_do_bloco": "...",
    "personagens": [
      {
        "nome": "nome principal, como aparece no texto",
        "apelidos": ["..."],
        "quem_e_ate_aqui": "..."
      }
    ]
  }
]

DETALHES
- Escreva em português do Brasil atual, em frases simples e diretas, mas mantenha os nomes de pessoas como aparecem no texto.
- Não copie frases do livro. Use suas palavras.
- Antes de fechar cada bloco, confira: o resumo_ate_aqui cobre a história desde o bloco 1? Cada fato está no texto até aqui? Os apelidos já juntados continuam lá?
- Se a resposta não couber, pare no fim de um bloco completo (nunca no meio de um objeto) e escreva a última linha exatamente assim: CONTINUA NO BLOCO N. Quando eu disser "continue do bloco N", siga a partir dele, no mesmo formato, começando uma nova lista.

O LIVRO:

