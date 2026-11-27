# Teste no Kindle

O que conferir no aparelho de verdade antes de dar a etapa 1 por encerrada. O teste no KOReader do computador (`ferramentas/testes/koreader/`) já cobre a lógica e o desenho das telas; este roteiro cobre o que só aparece no Kindle: toque, e-ink, desempenho e o uso do dia a dia.

**Aparelho de referência:** Kindle básico de 10ª geração (512 MB de RAM, 1 GHz, 167 ppi), com o KOReader em português do Brasil.

## Preparar

1. Copiar a pasta do repositório para `koreader/plugins/fuxico.koplugin` (sem `.git`).
2. Reiniciar o KOReader, **abrir um livro** e conferir que **Ferramentas › Fuxico** aparece. O menu só existe com um livro aberto (na lista de arquivos não aparece) e fica no fim da aba Ferramentas, que pode ter mais de uma página.
3. Ter à mão três livros EPUB:
   - um romance curto com nomes repetidos (por exemplo, *Dom Casmurro*);
   - um livro grande, de 1.000 páginas ou mais;
   - um livro sem sumário (sem capítulos marcados).

## Checklist

> **Com o Zen OS instalado:** antes de começar, ligue **Mostrar outros itens** nas configurações do Zen OS, em Destacar / Consultar › Consulta e em Destacar / Consultar › Destaque. Sem isso o Zen OS esconde o botão do Fuxico.

Anote em cada item: ✅ funcionou, ⚠️ funcionou com ressalva, ❌ não funcionou, com uma linha do que viu.

### Dicionário e menu de seleção

- [ ] Segurar o dedo num nome ("Capitu") abre o dicionário com o botão **Quem é esse?** embaixo.
- [ ] Segurar numa palavra comum ("cerca", "Então") abre o dicionário **sem** o botão.
- [ ] Tocar em **Quem é esse?** no dicionário fecha o dicionário e abre a gaveta.
- [ ] Nome composto ("José Dias") selecionado com o arraste mostra o botão no menu de seleção.
- [ ] Nome com acento ("Ângela", "Élio") mostra o botão.
- [ ] Com **Só em nomes próprios** desligado, o botão aparece em qualquer palavra.

### Busca

- [ ] A mensagem "Procurando menções… (toque para cancelar)" aparece e some.
- [ ] Tocar na mensagem cancela a busca sem travar o KOReader.
- [ ] **Tempo no romance curto:** ___ segundos.
- [ ] **Tempo no livro de 1.000 páginas** com um personagem principal: ___ segundos. Se passar de 10 s, anotar.
- [ ] O Kindle não fica sem responder durante a busca.

### Gaveta

- [ ] Abre por cima da página, com a página visível em cima.
- [ ] Os números batem: menções, "desde", "até a pág.".
- [ ] A miniatura da linha do tempo tem os tracinhos antes do cursor e o tracejado depois.
- [ ] **Cartão preto do aviso de sumiço:** o texto branco fica legível, e ao fechar a gaveta **não sobra fantasma** na página. Testar com um personagem que some por muitas páginas.
- [ ] Tocar num cartão leva ao trecho e fecha a gaveta.
- [ ] Tocar fora da gaveta fecha.
- [ ] Deslizar para baixo fecha.
- [ ] Com uma palavra que não é nome (forçando o botão com a proteção desligada e religada), aparece "Não parece ser um nome", e Dicionário, Buscar e "Mostrar mesmo assim" funcionam.

### Tela completa

- [ ] "Ver as N menções" abre a tela cheia, sem resto da gaveta por baixo.
- [ ] Os cartões cabem na tela e o rodapé mostra o intervalo ("1–5 de 103").
- [ ] Os botões ‹ e › e o deslizar para os lados trocam a página.
- [ ] "Recentes" e "Por capítulo" trocam a ordem e voltam para a primeira página.
- [ ] O X fecha a tela.
- [ ] A troca de página não deixa fantasma (é uma atualização parcial do e-ink).

### Ir e voltar

- [ ] Tocar numa menção pula para a página certa.
- [ ] O "voltar" do KOReader (gesto ou menu) retorna à página em que você estava.

### Menu e configurações

- [ ] **Ferramentas › Fuxico › Ajustes do "Quem é esse?"** mostra as quatro opções, e cada uma muda o comportamento.
- [ ] "Avisar quando sumiu por" abre o seletor de números, e o valor novo aparece no texto do item.
- [ ] "Abrir direto a tela completa" pula a gaveta.
- [ ] As opções continuam valendo depois de reiniciar o KOReader.
- [ ] "Sobre e privacidade" mostra a versão e o link do repositório.

### Tradução

- [ ] Toda a interface do Fuxico aparece em português, inclusive o nome e a descrição na lista de plugins. Se aparecer em inglês, procurar "Fuxico: tradução" no `koreader/crash.log`.
- [ ] Os plurais estão certos ("1 menção", "2 menções", "há 1 página").

### Casos difíceis

- [ ] Livro sem sumário: a gaveta mostra "pág. N" no lugar do capítulo, sem erro.
- [ ] Nome que só aparece uma vez (a seleção é a primeira menção): "Esta é a primeira menção.", sem botão de ver todas.
- [ ] Livro em PDF: o botão não aparece.
- [ ] Girar a tela com a gaveta aberta não trava (ela pode fechar).

## Depois do teste

- Anotar o resultado numa seção nova neste arquivo, com a data e a versão do KOReader.
- Abrir um item no roteiro para cada ❌ e cada ⚠️ que precise de correção.
- Se tudo passar, marcar o teste no Kindle no [roteiro](roteiro.md) e encerrar a etapa 1.

## Resultados

### 27/11/2026 · KOReader v2026.07.2 · Fuxico 0.1.0

Instalação. Primeira tentativa, ainda sem o checklist:

- ⚠️ O menu não aparecia em Ferramentas. Na verdade só aparece com um livro aberto, e o passo 2 dizia o contrário. O passo foi corrigido.
- ❌ Com o livro aberto, o menu apareceu em inglês ("Who is this?", "About and privacy"), embora o KOReader estivesse em `pt_BR` e o `.mo` estivesse instalado. A causa provável são outros plugins instalados no aparelho que substituem ou recarregam o `gettext`. A correção foi o catálogo de tradução próprio (veja a [arquitetura](arquitetura.md)). ✅ Com ela, o menu apareceu em português.
- ❌ Segurar o dedo num nome não mostrava o botão. Segurar numa palavra só abre direto o dicionário, não o menu de seleção, e o botão só existia no menu de seleção. O teste no computador não pegou o problema porque abria o menu de seleção direto. Agora o botão também aparece no dicionário, e o teste no computador passa por ele. Falta confirmar no aparelho.
- ⚠️ No Kindle de teste, o Zen OS esconde os botões de outros plugins no dicionário e no menu de seleção (`allow_unknown_items` desligado nas duas partes). O Fuxico não deve mudar a configuração de outro plugin, então a orientação foi para as docs: ligar **Mostrar outros itens** no Zen OS.
- ⚠️ O item "Quem é esse?" nas configurações parecia a própria função. Virou Ajustes do "Quem é esse?".
- ❌ Com a versão que põe o botão no dicionário instalada e **Mostrar outros itens** ligado no Zen OS, o botão **ainda não apareceu**. O teste parou aqui.

#### Onde paramos

**Funciona no Kindle:** o plugin carrega, o menu Ferramentas › Fuxico aparece com um livro aberto e a interface está em português.

**Não funciona no Kindle:** o botão "Quem é esse?" não aparece ao selecionar um nome. Sem ele, o resto do checklist não dá para testar no aparelho. No KOReader do computador, sem o Zen OS, o botão aparece no dicionário e no menu de seleção, e o roteiro automático passa inteiro (14 fotos).

**Instalado no Kindle:** o Fuxico do PR #4 (branch `fix/traducao-propria`, commit `20f2418`), com o catálogo de tradução próprio e o botão no dicionário.

**Ambiente do Kindle:** KOReader v2026.07.2, `default_highlight_action = "ask"`, sem `highlight_action_on_single_word`, sem `dict_button_config` (botões do dicionário nunca personalizados). Plugins que mexem no dicionário ou no menu de seleção: Zen OS (`dict_quick_lookup` e `highlight_lookup` ligados), além de Page Scrubber (`floating_dict.lua`) e Inline Hints.

#### O que ainda não sabemos

- Se o botão falhou no dicionário, no menu de seleção (arrastando sobre "José Dias", atrás do **Mais**) ou nos dois.
- Se o KOReader foi reiniciado depois de ligar **Mostrar outros itens**. O Zen OS lê a configuração na hora de montar a janela, mas não foi conferido.
- Se o Fuxico deu algum erro: o `koreader/crash.log` não foi lido depois dessa tentativa.

#### Hipóteses, da mais provável para a menos

1. **O dicionário do Zen OS em "Encaixar embaixo" (bottom sheet, ligado por padrão) não passa pelo `buildButtonLayout`.** O código lido (`zenos.koplugin/modules/reader/patches/dict_quick_lookup.lua`, linhas 311 a 460) só preserva os botões desconhecidos nesse caminho. Se a janela embaixo for montada em outro lugar, o botão do Fuxico some. Teste: desligar "Encaixar embaixo" em Destacar / Consultar › Consulta e segurar num nome de novo.
2. **A opção ligada não é a que vale.** `LookupPluginItems.shouldShow` (`modules/reader/lookup_plugin_items.lua`, linha 59) lê `config.dict_quick_lookup.allow_unknown_items` e `config.highlight_lookup.allow_unknown_items`. Teste: conferir as linhas 220 e 454 de `koreader/settings/ZenOS/config.lua`; as duas devem estar `true`.
3. **Outro plugin abre a palavra antes do dicionário do KOReader.** Page Scrubber tem um dicionário flutuante e Inline Hints mexe na seleção. Teste: desligar um de cada vez em Gerenciamento de plugins.
4. **O Fuxico registra o botão, mas a proteção recusa a palavra.** Pouco provável, porque no computador "Capitu" passa. Teste: desligar **Só em nomes próprios** e segurar em qualquer palavra.
5. **O Fuxico não chega a registrar o botão no dicionário** (por exemplo, se o Zen OS trocar o `ui.dictionary`). Teste: procurar "Fuxico" e "fuxico" no `crash.log` e ver se há erro.

#### Para continuar

1. Ligar o Kindle no cabo e ler `koreader/crash.log` e `koreader/settings/ZenOS/config.lua` (hipóteses 2 e 5).
2. No Kindle, testar em ordem: desligar "Encaixar embaixo" (1); arrastar sobre "José Dias" e abrir o **Mais** (descobre se o menu de seleção funciona); desligar **Só em nomes próprios** (4); desligar Page Scrubber e Inline Hints (3).
3. Se for o Zen OS, ler o caminho do bottom sheet no `dict_quick_lookup.lua` dele e decidir: integrar o Fuxico do jeito que o Zen OS reconhece, oferecer outro acesso (por exemplo, um gesto ou um item no menu que use a palavra selecionada) ou só documentar.
4. Com o botão aparecendo, retomar o checklist do começo.

