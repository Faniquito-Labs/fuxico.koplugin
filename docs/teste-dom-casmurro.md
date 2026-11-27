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

## Reproduzir

```
python -I ferramentas/teste-dom-casmurro/dividir.py
python -I ferramentas/teste-dom-casmurro/checar.py respostas/<ia>.txt
```

Os scripts esperam a pasta do teste com `fonte/dom-casmurro.txt` (texto do Gutenberg 55752), `blocos.json` e `respostas/`. Eles foram escritos para o teste e ainda não estão adaptados à estrutura deste repositório.
