# Teste com *Dom Casmurro*: Claude x Gemini

Feito em 26/11/2026, antes de escrever o plugin, para escolher a IA e calibrar o prompt.

## Como foi

- **Livro:** *Dom Casmurro*, edição Garnier de 1899 (Projeto Gutenberg nº 55752, domínio público, ortografia da época). 148 capítulos em 27 blocos de cerca de 2.400 palavras, sem cortar capítulo; 65 mil palavras.
- **Modo:** livro inteiro de uma vez. Cada IA recebe o livro todo em blocos numerados e devolve a memória de cada bloco como se tivesse lido só até ali.
- **Prompt:** versão 1 (a versão 2, corrigida a partir deste teste, está em [prompts/](../prompts/memoria-livro-inteiro.md)).
- **Checagem automática** ([`checar.py`](../ferramentas/teste-dom-casmurro/checar.py)): nome ou apelido citado antes de aparecer no texto, limites de palavras, blocos faltando.
- **Conferência manual:** 10 blocos sorteados (2, 3, 5, 7, 8, 10, 16, 17, 23, 27), cada afirmação comparada com o texto.

| | Gemini | Claude |
|---|---|---|
| Modelo | gemini-3.8-flash (AI Studio, grátis) | Claude Opus 5.5 (lendo o livro aos poucos) |
| Tempo | 4,5 min, 1 resposta | cerca de 7 min |

## Resultado

| Critério | Gemini | Claude |
|---|---|---|
| Blocos entregues | 27/27 | 27/27 |
| Spoilers de nome | 1 (um apelido citado 4 blocos antes) | 0 |
| Spoilers de enredo | 0 | 0 |
| Blocos sem erro (de 10) | 2 | 6 |
| Erros leves | 16 | 5 |
| Erros graves | 1 | 0 |
| Omissão do fato principal | 2 | 0 |
| `resumo_ate_aqui` acumula a história | não | sim |
| Apelidos mantidos entre blocos | não | sim |
| Português (1 a 5) | 4 | 5 |

**Spoiler:** os grandes acontecimentos do enredo aparecem nas duas IAs exatamente no bloco em que aparecem no livro.

**Erros típicos da Gemini:** intensificar o texto ("traços idênticos" onde o livro diz "semelhantes"), atribuir a fala ou a ideia a outra pessoa, inverter a ordem de dois acontecimentos (uma personagem que morre depois de outra chegar aparece morrendo antes) e um tom mais sugestivo do que o texto dá.

**Erros típicos do Claude:** detalhes de atribuição (quem revelou um plano) e pequenas generalizações.

## Decisões

1. **Claude como IA padrão por enquanto.** Melhor fidelidade e o único que manteve o resumo acumulado.
2. **Prompt v2** com uma regra de fidelidade ao texto, a definição explícita do `resumo_ate_aqui`, apelidos que se mantêm e texto em uma linha só. Ainda não testado.
3. **A Gemini não está descartada:** o problema do resumo acumulado deve sumir no modo aos poucos, em que cada pedido recebe a memória anterior. Testar quando o gerador existir.
4. **A checagem de "palavras do futuro" não serviu:** deu de 140 a 176 alertas, quase todos vocabulário comum. Candidata a ser trocada por um modelo de decisão barato que responda "isto revela algo que ainda não aconteceu?".

## Rodada 2: prompt v2

Mesmo livro, mesmos 10 blocos sorteados, só com o Claude. A memória não foi editada depois de escrita, nem para caber no limite de palavras. Os revisores desta rodada também checaram se o resumo acumula e se os apelidos se mantêm, então a revisão foi um pouco mais rigorosa.

| Critério | Claude, prompt v1 | Claude, prompt v2 |
|---|---|---|
| Spoilers de nome / de enredo | 0 / 0 | 0 / 0 |
| Blocos sem erro (de 10) | 6 | 3, mais 2 com só um detalhe |
| Erros leves | 5 | 12 |
| Erros graves | 0 | 0 |
| Omissão do fato principal | 0 | 0 |
| Limites de palavras estourados | 5 (enxugados antes da checagem) | 30 (`resumo_ate_aqui` até 140 palavras) |
| `resumo_ate_aqui` acumula | sim | sim |
| Apelidos | mantidos | mais completos, mas somem quando a pessoa sai das fichas |
| Português (1 a 5) | 5 | 4 e 5 |
| Tempo | cerca de 7 min | cerca de 7 min |

**Melhorou:** a atribuição (quem revela a viagem à Europa ficou certo), mais apelidos registrados e a ordem dos fatos no resumo do bloco.

**Não melhorou:** inferir o lugar da morte a partir do lugar do enterro, mesmo com a regra que proíbe inventar lugar.

**Piorou:** o limite de palavras. Resumir a história toda a cada bloco não cabe em 120 palavras.

**Conclusão:** a qualidade do v2 é parecida com a do v1. O que sobrou é problema de formato, não de prompt, e levou a três mudanças:
1. **Lista única de personagens** no `memoria.json`, que o plugin carrega adiante, em vez de 10 fichas por bloco ([formato](formato-memoria.md#personagens)).
2. **`resumo_ate_aqui` com até 150 palavras.**
3. **Checagem de limites** que pede para reescrever só o campo que estourou.

O próximo prompt (v3) será escrito para o modo aos poucos, já nesse formato.

## Rodada 3: prompt v3, aos poucos

Feita em 27/11/2026. Mesmo livro e mesmos blocos, agora no modo padrão do plugin. Um script ([`gerador_v3.py`](../ferramentas/teste-dom-casmurro/gerador_v3.py)) faz o papel do gerador:
- monta o pedido de cada bloco com a memória anterior e a lista única de personagens;
- entrega o pedido a uma instância nova do Claude, que vê só esse pedido, nunca o livro nem outros blocos;
- checa a resposta (limites de 150 / 50 / 30 palavras e nomes que ainda não apareceram) e, se falhar, pede a correção uma vez;
- junta tudo no `memoria.json`.

Para comparar, as quatro rodadas foram revisadas de novo nos mesmos 10 blocos sorteados. Um revisor por bloco viu as quatro versões anônimas e em ordem trocada, e conferiu cada uma com o texto. Como o revisor é outro e o mesmo para todas, os números não batem com as tabelas acima, mas são comparáveis entre si.

| Critério | Gemini, v1 | Claude, v1 | Claude, v2 | Claude, v3 |
|---|---|---|---|---|
| Modo | livro inteiro | livro inteiro | livro inteiro | aos poucos |
| Spoilers de nome (checagem) / de enredo (revisão) | 1 / 0 | 0 / 0 | 0 / 0 | 0 / 0 |
| Blocos sem erro (de 10) | 0 | 3, mais 2 com um só detalhe | 2, mais 5 com um só detalhe | 2, mais 5 com um só detalhe |
| Erros leves | 45 | 16 | 11 | 11 |
| Erros graves | 9 | 0 | 0 | 0 |
| Omissão do fato principal | 0 | 0 | 0 | 0 |
| `resumo_ate_aqui` acumula (de 10) | 0 | 9 | 10 | 10 |
| Português (média, 1 a 5) | 4,2 | 5,0 | 5,0 | 4,8 |
| `resumo_ate_aqui` (palavras, média / máximo) | 102 / 118 | 111 / 118 | 124 / 140 | 144 / 149 |
| Limites estourados na versão final | 0 | 0 (5 enxugados) | 30 | 0 (com 150; os 27 passam de 120) |
| Correções pedidas | — | — | — | 22 de 27 blocos |
| Personagens diferentes no livro | 21 | 23 | 15 | 47 |
| Tempo | 4,5 min | cerca de 7 min | cerca de 7 min | cerca de 28 min |

**Erros graves da Gemini:**
- em 7 blocos o `resumo_ate_aqui` não acumula: cobre só o bloco;
- uma inversão: "declara com firmeza", onde o texto diz que a fala saiu "aos pedaços";
- a ordem errada de uma morte.

**Erros leves do v3:**
- um que se propaga: José Dias diria que Bentinho e Capitu "podem namorar", quando ele só alerta para o risco. Como o resumo anterior entra em cada pedido, o erro do bloco 1 continua nos resumos seguintes;
- omissões menores no `resumo_do_bloco`, como os "olhos de ressaca";
- "Curitiba" em vez de "Corityba";
- o seminário datado em 1857, ano da denúncia.

**Lugar da morte:** o erro que sobrou no v2 sumiu. O v3 escreve que Capitu "é enterrada na Suíça" e que Ezequiel "é enterrado perto de Jerusalém", sem inventar onde morreram.

**Correções.** Das 43 falhas nas primeiras respostas:
- 33 foram fichas de protagonistas com 31 a 36 palavras;
- 8 foram resumos que passaram do limite por 1 a 3 palavras;
- 2 foram falsos alertas de nome ("pai", que o texto de 1899 escreve "pae").

Todas as correções passaram na checagem.

**Personagens:**
- **Inchaço:** a lista única não perdeu nenhum apelido, mas chegou a 47 pessoas, 27 delas figurantes de uma cena só ("uma senhora", "barbeiro", "irmãos Albuquerques").
- **Corte em 30:** a partir do bloco 16, os 30 do pedido deixaram de fora gente antiga. No bloco 20, o doutor João da Costa, que estava fora, voltou com outra grafia e só não virou duplicata porque o `id` gerado coincidiu.

**Conclusão:** no modo aos poucos o Claude mantém a fidelidade do v2, sem spoilers e com o resumo acumulado, e resolve o lugar da morte. O custo é tempo e tokens, cerca de 23 mil caracteres por pedido. Os problemas que sobraram são de instrução, não de modelo, e levaram ao [prompt v3.1](../prompts/memoria-aos-poucos.md):
- fichas reescritas e condensadas, em vez de só acrescentadas;
- margem nos resumos (cerca de 130 e 40 palavras);
- critério de quem entra na lista;
- outras grafias como apelido;
- os mais antigos no pedido sem ficha, em vez de cortados;
- um pedido de correção só para vários campos.

A Gemini ainda não foi testada no modo aos poucos, que pode resolver o resumo acumulado dela.

## Reproduzir

```
python -I ferramentas/teste-dom-casmurro/dividir.py
python -I ferramentas/teste-dom-casmurro/checar.py respostas/<ia>.txt
```

Os scripts esperam a pasta do teste com `fonte/dom-casmurro.txt` (texto do Gutenberg 55752), `blocos.json` e `respostas/`. Eles foram escritos para o teste e ainda não estão adaptados à estrutura deste repositório.

No modo aos poucos, o `gerador_v3.py` vai para a mesma pasta `scripts/` do `checar.py`. Para cada bloco N, em ordem:
1. `gerador_v3.py pedido N` monta o pedido em `v3/pedidos/`.
2. A IA responde em `v3/respostas/bloco-NN.json`.
3. `gerador_v3.py checar N` checa a resposta. Se falhar, grava o pedido de correção em `v3/correcoes/` e a IA responde de novo, na mesma conversa.
4. `gerador_v3.py incorporar N` junta a resposta ao `memoria.json`.

No fim, `gerador_v3.py final` gera `respostas/claude-v3.txt` no formato que o `checar.py` lê. O prompt é lido deste repositório (ou do indicado em `FUXICO_REPO`). Para avaliar o v3, lembre que o `checar.py` ainda usa o limite de 120 palavras para o resumo acumulado.
