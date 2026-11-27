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

Anote em cada item: ✅ funcionou, ⚠️ funcionou com ressalva, ❌ não funcionou, com uma linha do que viu.

### Menu de seleção

- [ ] Segurar o dedo num nome ("Capitu") mostra o botão **Quem é esse?**.
- [ ] Segurar numa palavra comum ("cerca", "Então") **não** mostra o botão.
- [ ] Nome composto ("José Dias") selecionado com o arraste mostra o botão.
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

- [ ] **Ferramentas › Fuxico › Quem é esse?** mostra as quatro opções, e cada uma muda o comportamento.
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
- ❌ Com o livro aberto, o menu apareceu em inglês ("Who is this?", "About and privacy"), embora o KOReader estivesse em `pt_BR` e o `.mo` estivesse instalado. A causa provável são outros plugins instalados no aparelho que substituem ou recarregam o `gettext`. A correção foi o catálogo de tradução próprio (veja a [arquitetura](arquitetura.md)), e a versão corrigida já foi instalada no Kindle. Falta confirmar no aparelho.

