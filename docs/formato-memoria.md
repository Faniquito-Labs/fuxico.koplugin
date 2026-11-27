# Formato da memória (`memoria.json`)

Versão do formato: **1** (rascunho; ainda não há memória gerada neste formato).

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
      "fios_soltos": ["…", "…"],
      "presentes": ["bentinho", "jose-dias", "d-gloria", "capitu"],
      "checagem": { "spoiler_nome": 0, "limites": 0, "refeito": false }
    }
  ],
  "personagens": [
    {
      "id": "bentinho",
      "nome": "Bentinho",
      "tipo": "pessoa",
      "desde_bloco": 1,
      "apelidos": [
        { "apelido": "Dom Casmurro", "desde_bloco": 1 },
        { "apelido": "Bento", "desde_bloco": 3 }
      ],
      "fichas": [
        { "bloco": 1, "quem_e_ate_aqui": "…" },
        { "bloco": 3, "quem_e_ate_aqui": "…" }
      ]
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
- `resumo_ate_aqui`: até 150 palavras, a história desde o início.
- `resumo_do_bloco`: até 50 palavras, só o bloco.
- `fios_soltos`: até 3 itens de até 15 palavras, o que está em aberto na história até o fim do bloco (promessas, dúvidas, conflitos sem resposta). É a lista inteira naquele ponto, não só o que mudou. Mostrado no "O que rolou?". Entrou no prompt v3.2; memórias geradas antes não têm o campo.
- `presentes`: `id` das pessoas (até 10) e dos lugares (até 3) que importam neste bloco. É o que o "Quem tá na cena?" mostra.
- `checagem`: resultado da checagem de spoiler e de limites.

No modo nuvem, o arquivo é gravado aos poucos: só existem os blocos já gerados.

### `personagens`
Uma lista única e cumulativa para o livro todo, com **pessoas e lugares** (desde o prompt v3.3; o nome da chave ficou `personagens` para não quebrar memórias antigas). Ninguém sai dela: quem some da história por alguns capítulos continua com o nome, os apelidos e a última ficha.
- `id`: identificador fixo, sem acentos.
- `tipo`: `"pessoa"` ou `"lugar"`. Memórias geradas antes do v3.3 não têm o campo e são lidas como `"pessoa"`.
- `desde_bloco`: primeiro bloco em que a pessoa aparece no texto.
- `apelidos`: cada um com o bloco em que o texto deixou claro que é a mesma pessoa.
- `fichas`: o "quem é até aqui" (até 30 palavras), com uma entrada nova só quando o leitor descobre algo novo sobre a pessoa.

**Como "Quem é esse?" consulta, estando no bloco N:**
1. Procura o nome tocado entre os `nome` e `apelidos` com `desde_bloco` ≤ N.
2. Mostra a última ficha com `bloco` ≤ N e só os apelidos já conhecidos.
3. Se não achar, cai no modo sem IA.

**Por que mudou:** no teste com *Dom Casmurro*, as fichas eram 10 por bloco. Quando um personagem saía da lista, os apelidos sumiam junto ("Tartaruga" e "Joãosinho" de Padua, "Nanata" de D. Fortunata). Ver [teste-dom-casmurro.md](teste-dom-casmurro.md).

### O que a IA devolve por bloco

O plugin monta a lista cumulativa; a IA só devolve o que mudou:

```json
{
  "bloco": 3,
  "resumo_ate_aqui": "…",
  "resumo_do_bloco": "…",
  "fios_soltos": ["…"],
  "presentes": ["bentinho", "capitu", "padre-cabral"],
  "personagens_novos_ou_atualizados": [
    { "id": "bentinho", "apelidos_novos": ["Bento"], "quem_e_ate_aqui": "…" },
    { "id": "padre-cabral", "nome": "Padre Cabral", "tipo": "pessoa", "apelidos_novos": [], "quem_e_ate_aqui": "…" },
    { "id": "matacavalos", "nome": "Matacavalos", "tipo": "lugar", "apelidos_novos": [], "quem_e_ate_aqui": "…" }
  ]
}
```

A IA recebe junto a lista atual de personagens (só `id`, `nome`, apelidos e a última ficha), para reaproveitar os `id` e não criar duplicatas. Acima de 30 personagens, os 30 mais recentes vão com a ficha e os outros só com `id`, `nome` e apelidos: assim quem volta à história depois de muito tempo não é recriado como novo.

### Limites

Se um campo passar do limite, o gerador pede para reescrever só aquele campo, uma vez. Se passar de novo, aceita como está e marca em `checagem.limites`.

## Posição no texto

O número da página muda com a fonte e a margem, então a memória usa a posição no texto:

- **`fragmento`**: o número do arquivo HTML dentro do EPUB, na ordem de leitura (o *spine*). É o mesmo `DocFragment[N]` que aparece nas posições (*xpointers*) do KOReader.
- **`palavra`**: quantas palavras há do início do fragmento até aquele ponto.

O processador no PC conhece o *spine* do EPUB e conta as palavras. No Kindle, o plugin converte a posição atual do KOReader para (fragmento, palavra) extraindo o texto do início do fragmento até a posição atual.

**Qual bloco mostrar:** o último bloco cujo `fim` já ficou para trás. Se o leitor está no meio de um bloco, as telas usam o bloco anterior completo. *O que rolou?* pode acrescentar o resumo do bloco atual quando mais de 80% dele foi lido.

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
