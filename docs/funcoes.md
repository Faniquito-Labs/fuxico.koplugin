# Funções

Cada função tem duas versões: **com memória**, quando o livro tem um `memoria.json`, e **sem IA**, quando não tem (nenhuma IA configurada, sem Wi-Fi ou livro ainda não processado). O modo sem IA nunca escreve resumo; ele só mostra trechos do próprio livro, que nunca saem do Kindle.

Em todas elas, a regra é a mesma: **nada depois da posição atual de leitura**.

## Quem é esse?

**Como abre:** segurar o dedo sobre um nome e escolher "Quem é esse?" no menu de seleção.

**Com memória:**
- Procura o nome entre os nomes e apelidos das fichas do último bloco já lido.
- Mostra o nome principal, os apelidos conhecidos até aqui e o "quem é até aqui".
- Se o nome não estiver nas fichas, cai no modo sem IA.

**Sem IA:**
- Primeira aparição do nome no livro, com a frase em volta e o capítulo.
- As últimas 3 a 5 menções antes da posição atual.
- Toque numa menção para ir até ela (com "voltar" para onde estava).

## Previamente em…

**Como abre:** menu do plugin, ou automaticamente ao abrir um livro parado há mais de N dias (configurável, desligado por padrão).

**Com memória:** o `resumo_ate_aqui` do último bloco lido por inteiro, seguido do `resumo_do_bloco` do bloco atual, se ele já tiver sido lido em boa parte.

**Sem IA:** não disponível. A tela explica como gerar a memória.

## X-Ray do capítulo

**Como abre:** menu do plugin, ou um toque no canto da tela (configurável).

**Com memória:** lista as fichas do bloco atual, com a descrição de cada personagem até aqui.

**Sem IA:** detecta palavras com letra maiúscula no meio da frase, do início do capítulo até a posição atual, e lista as mais frequentes. Ignora palavras comuns em início de frase e uma lista de palavras que não são nomes (dias da semana, meses, "Deus", "Senhor"...).

## Onde você parou

**Como abre:** ao abrir o livro (configurável), ou pelo menu.

**Com memória:** o `resumo_do_bloco` do trecho em que você está, mais a posição em capítulo e percentual.

**Sem IA:** o último parágrafo lido antes de fechar o livro.

## Configurações previstas

- Modo de geração: nenhum (só sem IA), nuvem ou PC
- Serviço de IA e chave de API (só no modo nuvem)
- Gerar à frente quantos capítulos
- Gerar só no Wi-Fi e com bateria acima de X%
- Abrir "Previamente em…" ao retomar depois de N dias
- Apagar a memória deste livro
