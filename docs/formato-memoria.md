# Formato da memória (`memoria.json`)

Versão do formato: **1** (rascunho).

## Exemplo

```json
{
  "formato": 1,
  "livro": {
    "titulo": "Dom Casmurro",
    "autor": "Machado de Assis",
    "idioma": "pt-BR",
    "isbn": null,
    "chave": "a3f9c2e17b0d4e58",
    "impressoes": [
      { "fragmento": 2, "hash": "5e1c09ab" },
      { "fragmento": 3, "hash": "c77d2f10" }
    ]
  },
  "geracao": {
    "modo": "nuvem",
    "servico": "claude",
    "modelo": "claude-opus-5-5",
    "prompt": "v2",
    "data": "2026-11-26"
  },
  "blocos": [
    {
      "bloco": 1,
      "inicio": { "fragmento": 2, "palavra": 0 },
      "fim": { "fragmento": 6, "palavra": 812 },
      "capitulos": ["I", "V"],
      "resumo_ate_aqui": "…",
      "resumo_do_bloco": "…",
      "personagens": [
        {
          "nome": "Bentinho",
          "apelidos": ["Dom Casmurro"],
          "quem_e_ate_aqui": "…"
        }
      ],
      "checagem": { "spoiler_nome": 0, "refeito": false }
    }
  ]
}
```

## Campos

### `livro`
- `chave`: identifica a edição. Duas cópias do mesmo EPUB têm a mesma chave; outra tradução ou outra edição tem chave diferente.
- `impressoes`: uma por fragmento com pelo menos 50 palavras. Servem para reconhecer o livro e para conferir se a memória bate com o arquivo aberto.
- `isbn`: do metadado do EPUB, quando existir. Ajuda a achar edições, mas não basta sozinho.

### `geracao`
De onde veio a memória. Permite refazer quando o prompt mudar de versão.

### `blocos`
Em ordem, sem buracos. Cada bloco tem a memória **de quem leu até o fim dele**.
- `inicio` / `fim`: posição no texto (ver abaixo).
- `capitulos`: primeiro e último capítulo do bloco, só para exibir.
- `resumo_ate_aqui`: até 120 palavras, a história desde o início.
- `resumo_do_bloco`: até 50 palavras, só o bloco.
- `personagens`: até 10 fichas, com `quem_e_ate_aqui` de até 30 palavras.
- `checagem`: resultado da checagem de spoiler.

No modo nuvem, o arquivo é gravado aos poucos: só existem os blocos já gerados.

## Posição no texto

O número da página muda com a fonte e a margem, então a memória usa a posição no texto:

- **`fragmento`**: o número do arquivo HTML dentro do EPUB, na ordem de leitura (o *spine*). É o mesmo `DocFragment[N]` que aparece nas posições (*xpointers*) do KOReader.
- **`palavra`**: quantas palavras há do início do fragmento até aquele ponto.

O processador no PC conhece o *spine* do EPUB e conta as palavras. No Kindle, o plugin converte a posição atual do KOReader para (fragmento, palavra) extraindo o texto do início do fragmento até a posição atual.

**Qual bloco mostrar:** o último bloco cujo `fim` já ficou para trás. Se o leitor está no meio de um bloco, as telas usam o bloco anterior completo. *Previamente em…* pode acrescentar o resumo do bloco atual quando mais de 80% dele foi lido.

*(A confirmar na implementação: se a contagem de palavras no Kindle bate com a do PC. A regra de contagem tem de ser a mesma dos dois lados: separar por espaço depois de tirar tags.)*

## Chave do livro

1. Para cada fragmento, na ordem, pegar o texto sem tags.
2. Normalizar: minúsculas, sem acentos, sem pontuação, espaços simples.
3. Se tiver pelo menos 50 palavras, a impressão do fragmento é o SHA-1 das 50 primeiras palavras (primeiros 8 caracteres hexadecimais).
4. A `chave` é o SHA-1 de todas as impressões em ordem, separadas por `|` (primeiros 16 caracteres hexadecimais).

O texto nunca é enviado: só as impressões, que não permitem reconstruí-lo.

## Compatibilidade

- Um leitor do formato 1 ignora campos que não conhece.
- Mudança que quebra compatibilidade aumenta `formato`.
