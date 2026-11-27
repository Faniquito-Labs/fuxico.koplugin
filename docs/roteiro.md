# Roteiro

## Feito

- [x] Teste de qualidade das IAs com *Dom Casmurro* no modo livro inteiro ([resultado](teste-dom-casmurro.md))
- [x] Prompt v2, corrigido a partir dos erros do teste, e segunda rodada do Claude com ele ([resultado](teste-dom-casmurro.md#rodada-2-prompt-v2))
- [x] Formato da memória com lista única de personagens ([formato](formato-memoria.md))
- [x] Documentação inicial
- [x] Design do "Quem é esse?", do "O que rolou?" e do menu de configurações, com as funções nomeadas como perguntas ([design](design.md), [funções](funcoes.md))

## 1. "Quem é esse?" sem IA

A primeira função, sem depender de nada externo.

- [ ] Esqueleto do plugin (`_meta.lua`, `main.lua`, tradução pt-BR)
- [ ] Menu inicial em Ferramentas › Fuxico: "Quem é esse?" e "Sobre e privacidade"
- [ ] "Quem é esse?" no menu de seleção de texto, com a camada 1 da proteção (só nomes próprios)
- [ ] Busca de todas as menções até a posição atual, em segundo plano
- [ ] Camada 2 da proteção ("Não parece ser um nome", com Dicionário e Buscar)
- [ ] Gaveta sem memória: resumo, aviso de sumiço, miniatura da linha do tempo, última vez, primeira aparição
- [ ] Tela completa: linha do tempo grande, filtros e cartões
- [ ] Ir até a menção guardando a posição para o "voltar" nativo
- [ ] Testar no Kindle 10ª geração: tempo de busca num livro de 1.000 páginas e o cartão escuro no e-ink

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
- [ ] Testar o prompt v3.2 (o v3.1 com fichas condensadas, quem entra na lista e personagens antigos sem ficha, mais os fios soltos) e a Gemini no modo aos poucos

## 3. Telas que usam a memória

- [ ] "Quem é esse?" com ficha: tipo, apelidos, rodapé (atualizada em, primeira vez, aparece mais com) e histórico da ficha
- [ ] O que rolou? (com e sem memória), na medida do tempo parado, com o aviso ao abrir um livro parado
- [ ] "Da última vez você leu…" e "Na sua última sessão", a partir das estatísticas do KOReader
- [ ] Fios soltos no O que rolou?
- [ ] Botão "Começo do capítulo"
- [ ] Quem tá na cena?
- [ ] Onde eu parei?
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
