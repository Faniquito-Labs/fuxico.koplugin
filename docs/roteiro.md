# Roteiro

## Feito

- [x] Teste de qualidade das IAs com *Dom Casmurro* no modo livro inteiro ([resultado](teste-dom-casmurro.md))
- [x] Prompt v2, corrigido a partir dos erros do teste, e segunda rodada do Claude com ele ([resultado](teste-dom-casmurro.md#rodada-2-prompt-v2))
- [x] Formato da memória com lista única de personagens ([formato](formato-memoria.md))
- [x] Documentação inicial
- [x] Design das quatro funções ("Quem é esse?", "O que rolou?", "Quem tá na cena?" e "Onde eu parei?") e do menu de configurações, com as funções nomeadas como perguntas ([design](design.md), [funções](funcoes.md))

## 1. "Quem é esse?" sem IA

A primeira função, sem depender de nada externo. Os itens marcados funcionam no KOReader do computador; falta o teste no Kindle.

- [x] Esqueleto do plugin (`_meta.lua`, `main.lua`, tradução pt-BR)
- [x] Menu inicial em Ferramentas › Fuxico: "Quem é esse?" e "Sobre e privacidade"
- [x] "Quem é esse?" no menu de seleção de texto, com a camada 1 da proteção (só nomes próprios)
- [x] "Quem é esse?" também no dicionário, que é o que abre ao segurar o dedo numa palavra só
- [x] Busca de todas as menções até a posição atual, em segundo plano
- [x] Camada 2 da proteção ("Não parece ser um nome", com Dicionário e Buscar)
- [x] Gaveta sem memória: resumo, aviso de sumiço, miniatura da linha do tempo, última vez, primeira aparição
- [x] Tela completa: linha do tempo grande, filtros e cartões
- [x] Ir até a menção guardando a posição para o "voltar" nativo
- [x] Ferramentas de tradução (extrair e compilar) e testes da lógica sem IA
- [x] Testar no KOReader do computador, com o teste automático de `ferramentas/testes/koreader/` (27/11/2026, KOReader para Mac v2026.07.2)
- [ ] Fazer o botão "Quem é esse?" aparecer no Kindle com o Zen OS instalado (parado em 27/11/2026; veja [onde paramos](teste-no-kindle.md#onde-paramos))
- [ ] Testar no Kindle 10ª geração, seguindo o [checklist do teste no Kindle](teste-no-kindle.md): menu de seleção, tempo de busca num livro de 1.000 páginas, gaveta e fantasma do cartão preto no e-ink, tela completa, ir e voltar, menu, tradução e casos difíceis

## 2. Memória direto no Kindle

- [ ] Conversão de posição do KOReader para (fragmento, palavra)
- [ ] Divisão em blocos no Kindle
- [ ] Gravar e ler o `memoria.json` na pasta `.sdr`
- [ ] Serviço de IA: Claude primeiro, com interface comum para os outros
- [ ] Geração aos poucos, à frente da leitura, só com Wi-Fi e bateria suficiente
- [x] Prompt v3 para o modo aos poucos, já no formato da lista única de personagens ([prompt](../prompts/memoria-aos-poucos.md))
- [ ] Checagem de spoiler de nomes e de limites de palavras, com nova tentativa só do que falhou
- [ ] Menu "Memória deste livro": estado, gerar agora, gerar à frente, modo releitura, desligar neste livro, apagar
- [ ] Menu "Inteligência artificial": modo, serviço, chave mascarada, importar chave de arquivo, testar conexão
- [ ] Gerar só no Wi-Fi, só carregando ou com bateria mínima
- [ ] Contador de uso no mês e limite mensal opcional
- [x] Testar o prompt v3: rodar o modo aos poucos com *Dom Casmurro* e comparar com as rodadas do livro inteiro ([resultado](teste-dom-casmurro.md#rodada-3-prompt-v3-aos-poucos))
- [x] Prompt v3.2: fios soltos ([prompt](../prompts/memoria-aos-poucos.md)), com o gerador do teste já preparado para o campo novo
- [x] Prompt v3.3: lugares na lista, com `tipo` pessoa ou lugar, e o gerador do teste preparado para isso
- [ ] Testar o prompt v3.3 (o v3.1 com fichas condensadas, quem entra na lista e personagens antigos sem ficha, mais os fios soltos do v3.2 e os lugares do v3.3) e a Gemini no modo aos poucos

## 3. Telas que usam a memória

- [ ] "Quem é esse?" com ficha: tipo, apelidos, rodapé (atualizada em, primeira vez, aparece mais com) e histórico da ficha
- [ ] O que rolou? (com e sem memória), na medida do tempo parado, com o aviso ao abrir um livro parado
- [ ] "Da última vez você leu…" e "Na sua última sessão", a partir das estatísticas do KOReader
- [ ] Fios soltos no O que rolou?
- [ ] Botão "Começo do capítulo"
- [ ] Quem tá na cena? (com e sem memória): "Nesta página", "Também neste trecho" e "Onde"
- [ ] Onde eu parei? (com e sem memória): progresso no capítulo, tempo para terminar e últimas paradas a partir das estatísticas do KOReader
- [ ] Ações para o Gerenciador de gestos do KOReader

## 4. Modo privado no PC

- [ ] Processador em Python: EPUB → blocos → Ollama → `memoria.json`
- [ ] Integração com o Calibre
- [ ] Levar o arquivo para o Kindle junto com o livro
- [ ] Medir tempo e qualidade na GTX 1650 (modelos de 4B e 8B)

## 5. Acabamento

- [ ] Apelidos e nomes compostos
- [ ] Livros sem capítulos
- [ ] Livros muito longos
- [ ] Publicar no `koreader/contrib` e nas lojas de plugins (App Store, Storefront)

## Depois

- [ ] Base compartilhada, fase 1: domínio público com curadoria ([detalhes](base-compartilhada.md))
- [ ] Estante de Clássicos Brasileiros
- [ ] Exportar e importar a memória de um livro
- [ ] "Também se chama…": juntar nomes à mão no modo sem IA
- [ ] Livro anterior da série no O que rolou?, e o "Quem é esse?" procurando também na memória do volume anterior
