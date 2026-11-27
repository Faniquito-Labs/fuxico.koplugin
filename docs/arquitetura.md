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
- Um pedido por bloco, pequeno: cerca de 6 mil tokens de entrada e 1 mil de saída ([prompt v3.1](../prompts/memoria-aos-poucos.md)).
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

Estrutura padrão de plugin do KOReader:

```
bulhufas.koplugin/
  _meta.lua             nome e descrição
  main.lua              registra menus, eventos e o item "Quem é esse?" na seleção
  memoria.lua           lê, grava e consulta o memoria.json
  posicao.lua           converte a posição do KOReader para (fragmento, palavra)
  semia.lua             buscas do modo sem IA
  gerador.lua           divide em blocos e chama a IA (modo nuvem)
  servicos/             um arquivo por serviço de IA
  telas/                as telas (Quem é esse?, Previamente em..., X-Ray, Onde você parou)
  l10n/                 traduções (pt_BR como idioma principal)
```

Pontos do KOReader a usar (a confirmar na implementação):
- Evento `onReaderReady` para checar a memória ao abrir o livro.
- `ui.highlight` para adicionar "Quem é esse?" ao menu de seleção de texto.
- `ui.document:getXPointer()` e funções de texto do crengine para posição e extração do texto.
- `NetworkMgr` para esperar o Wi-Fi.
- `DocSettings` para achar a pasta `.sdr` do livro.

## Limites conhecidos

- **PDF:** fora do escopo inicial (posição e texto funcionam diferente). Os manuais de jogos em PDF não usam o plugin.
- **Livros com DRM** (comprados na Amazon): não abrem no KOReader, então ficam de fora.
- **Livros sem capítulos:** viram blocos por contagem de palavras.
- **Livros muito longos:** a memória cresce com o livro; o `resumo_ate_aqui` continua limitado a 150 palavras, então o começo vai sendo condensado.
