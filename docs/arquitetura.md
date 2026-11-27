# Arquitetura

## Visão geral

```
                    GERAÇÃO (uma vez por livro)                       LEITURA (sempre offline)

 Modo nuvem   Kindle ──(blocos do texto, Wi-Fi)──> IA na nuvem
              Kindle <──(memória do bloco)──────── (Gemini, Claude...)
                 │                                                    Kindle lê memoria.json
                 └──────> grava memoria.json ─────────────────────>   e mostra as telas
                                                                      (sem internet)
 Modo PC      Calibre ──> processador no PC ──> Ollama (IA local)
                               │
                               └──> memoria.json vai junto com o livro ──>

 Sem IA       (nada é gerado; as telas usam buscas no próprio texto)
```

Princípios:

1. **A leitura nunca depende de internet.** Toda tela lê o `memoria.json` ou o próprio livro.
2. **Não há servidor rodando durante a leitura.** A base compartilhada (fase futura) só é consultada para baixar uma memória pronta.
3. **IA dentro do Kindle é impossível.** Com 512 MB de RAM, não cabe nem o menor modelo útil.
4. **Posição, não página.** O número da página muda com fonte e margem; a memória é indexada pela posição no texto (ver [formato-memoria.md](formato-memoria.md)).

## Como a memória é gerada

O livro é dividido em **blocos**: capítulos inteiros agrupados até cerca de 2 mil palavras. Um capítulo muito longo vira mais de um bloco, cortado em fim de parágrafo.

Para cada bloco, em ordem, a IA recebe:
- a memória até o bloco anterior (resumo acumulado e a lista de personagens já conhecidos, com a última ficha de cada um; acima de 30 personagens, os mais antigos vão sem ficha);
- o texto do bloco.

E devolve a memória até este bloco: `resumo_ate_aqui`, `resumo_do_bloco`, quem está presente e só os personagens novos ou com algo novo. O plugin junta isso numa lista única de personagens, que nunca perde ninguém (ver [formato-memoria.md](formato-memoria.md#personagens)). O prompt está em [prompts/](../prompts/).

**Por que bloco a bloco, e não o livro inteiro de uma vez?** Porque a IA só vê o texto até aquele ponto, o que reduz o risco de spoiler, e porque o resumo acumulado sai melhor. No teste com *Dom Casmurro* (ver [teste-dom-casmurro.md](teste-dom-casmurro.md)), o modo livro inteiro funcionou bem no Claude, mas a Gemini não acumulou o resumo. O modo livro inteiro continua útil para gerar memórias de referência no PC.

**Risco que sobra:** em livros famosos, a IA pode "conhecer" o final mesmo sem vê-lo. O prompt manda ignorar esse conhecimento, e a checagem de spoiler (ver abaixo) pega parte dos deslizes.

## Modo nuvem (padrão)

- Ao abrir o livro, o plugin verifica quantos blocos à frente da posição atual já têm memória. Se faltar, e houver Wi-Fi, gera os próximos (configurável, por exemplo 2 capítulos à frente).
- Um pedido por bloco, pequeno: cerca de 6 mil tokens de entrada e 1 mil de saída ([prompt v3.3](../prompts/memoria-aos-poucos.md)).
- A geração roda em segundo plano e para se o Wi-Fi cair ou a bateria baixar do limite configurado.
- A chave de API fica nas configurações do plugin, só no Kindle.

**Serviços considerados:**

| Serviço | Custo | Observação |
|---|---|---|
| Claude (API) | pago | melhor qualidade no teste; escolhido por enquanto |
| Gemini | grátis com limites | no plano grátis, o Google pode usar o texto para treinar |
| DeepSeek | pago, barato | servidores na China |
| Groq | grátis com limite por minuto | limite atrapalha pouco no modo aos poucos |

O plugin deve aceitar mais de um serviço por trás da mesma interface (`gerar_bloco(memoria_anterior, texto) -> memoria`).

## Modo PC (privado)

- Um programa no PC (Python) observa a biblioteca do Calibre ou é chamado por um plugin do Calibre.
- Quando um EPUB entra, divide em blocos, gera a memória com o Ollama e grava o `memoria.json`.
- Na GTX 1650 (4 GB): modelos de 4B levam de 30 a 45 min por livro; os de 8B, cerca de 2 h (estimativas sem teste).
- O arquivo vai para o Kindle junto com o livro (ver "Onde os arquivos ficam").

## Modo sem IA

Funciona sempre, como plano B. Só busca no texto do livro, no próprio Kindle. Detalhes em [funcoes.md](funcoes.md).

## Checagem de spoiler

Roda depois de gerar cada bloco, no Kindle ou no PC:

- Todo nome e apelido citado na memória do bloco N precisa aparecer no texto até o bloco N. Se não aparecer, o bloco é refeito uma vez; se falhar de novo, o nome é removido e o bloco é marcado.
- Todo campo precisa respeitar o limite de palavras. Se passar, só aquele campo é reescrito, uma vez.
- Verificação de enredo (opcional, futura): um modelo barato de decisão responde "este resumo revela algo que não está no texto até aqui?".

O script do teste (`checar.py`) é a primeira versão dessa checagem.

## Onde os arquivos ficam

O KOReader guarda os dados de cada livro numa pasta ao lado dele: `Livro.epub` → `Livro.sdr/`. A memória fica ali:

```
Livros/
  Dom Casmurro.epub
  Dom Casmurro.sdr/
    metadata.epub.lua       (do KOReader)
    memoria.json            (deste plugin)
```

No modo PC, o Calibre manda só o livro. O processador grava `Dom Casmurro.memoria.json` ao lado do EPUB, e o plugin, ao abrir o livro, move o arquivo para dentro da pasta `.sdr`. *(A confirmar: se o envio sem fio do Calibre aceita arquivos extras. Se não, a alternativa é copiar pelo USB ou o plugin baixar do PC pela rede de casa.)*

## Peças do plugin

O repositório é a própria pasta do plugin. `_meta.lua` e `main.lua` ficam na raiz, como o KOReader exige; o resto fica dentro de `fuxico/`, para os módulos serem carregados como `require("fuxico/...")` e não colidirem com arquivos de mesmo nome de outros plugins (o KOReader junta as pastas de todos os plugins no mesmo caminho de busca).

```
fuxico.koplugin/
  _meta.lua                 nome, descrição e versão
  main.lua                  carrega a tradução, registra o menu e o "Quem é esse?" na seleção, faz a busca
  fuxico/
    semia.lua               buscas do modo sem IA e a proteção de nomes próprios     (etapa 1)
    configuracoes.lua       configurações gerais, em fuxico.lua na pasta do KOReader (etapa 1)
    menu.lua                o menu em Ferramentas › Fuxico                           (etapa 1)
    telas/                  gaveta_quem_e.lua e tela_mencoes.lua                     (etapa 1)
    componentes/            estilo, cartão e linha do tempo                          (etapa 1)
    memoria.lua             lê, grava e consulta o memoria.json                      (etapa 2)
    posicao.lua             converte a posição do KOReader para (fragmento, palavra) (etapa 2)
    gerador.lua             divide em blocos e chama a IA (modo nuvem)               (etapa 2)
    servicos/               um arquivo por serviço de IA                             (etapa 2)
  l10n/                     fuxico.pot e uma pasta por idioma (pt_BR/fuxico.po e .mo)
  ferramentas/l10n/         extrair.py (gera o .pot) e compilar.py (gera os .mo e confere a tradução)
  ferramentas/testes/       testar.py: sintaxe de todo .lua e testes do semia.lua
```

Os textos da interface são escritos em inglês no código, como no resto do KOReader, e traduzidos em `l10n/`. O português do Brasil é a tradução principal e tem de estar sempre completa (`compilar.py` falha se faltar algo).

A lógica (busca, proteção, leitura da memória) fica separada das telas, para o visual mudar sem mexer na busca.

Pontos do KOReader a usar. Os marcados com ✓ foram conferidos no código do KOReader v2026.07 em 27/11/2026:
- ✓ `ui.highlight:addToHighlightDialog(id, função)` acrescenta o botão "Quem é esse?" ao menu de seleção. A função recebe o `ReaderHighlight`, de onde sai `selected_text.text`, e pode esconder o botão com `show_in_highlight_dialog_func` (é onde entra a camada 1 da proteção).
- ✓ `ui.document:findAllText(padrão, ignorar_maiúsculas, palavras_de_contexto, máximo, regex, flags)` busca no livro inteiro e devolve, para cada ocorrência, `start` e `end` (xpointers), `prev_text`, `matched_text` e `next_text`. A busca do próprio KOReader roda dentro de `Trapper:dismissableRunInSubprocess`, para não travar e poder ser cancelada; o Fuxico faz igual.
- ✓ `ui.document:getXPointer()` dá a posição atual, e `ui.document:compareXPointers(a, b)` diz se `b` vem depois de `a` (1), antes (-1) ou é igual (0). É o que corta tudo depois da posição atual.
- ✓ `ui.document:getPageFromXPointer(xp)` dá a página, para "até a pág. 71" e "há 2 páginas".
- ✓ `ui.toc:getTocTitleByPage(xp)` dá o título do capítulo de uma ocorrência.
- ✓ `ui.link:addCurrentLocationToStack()` seguido de `ui.rolling:onGotoXPointer(xp)` pula até uma menção guardando a posição para o "voltar" nativo.
- ✓ `ui.menu:registerToMainMenu(plugin)` com `addToMainMenu(menu_items)` cria o menu do plugin.
- ✓ Traduções do plugin carregadas com `gettext.loadMO(caminho)`, como faz o AnnotationSync.
- Evento `onReaderReady` para checar a memória ao abrir o livro.
- `NetworkMgr` para esperar o Wi-Fi.
- `DocSettings` para achar a pasta `.sdr` do livro.

## Limites conhecidos

- **PDF:** fora do escopo inicial (posição e texto funcionam diferente). Os manuais de jogos em PDF não usam o plugin.
- **Livros com DRM** (comprados na Amazon): não abrem no KOReader, então ficam de fora.
- **Livros sem capítulos:** viram blocos por contagem de palavras.
- **Livros muito longos:** a memória cresce com o livro; o `resumo_ate_aqui` continua limitado a 150 palavras, então o começo vai sendo condensado.
