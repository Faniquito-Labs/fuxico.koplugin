# Roteiro

## Feito

- [x] Teste de qualidade das IAs com *Dom Casmurro* no modo livro inteiro ([resultado](teste-dom-casmurro.md))
- [x] Prompt v2, corrigido a partir dos erros do teste, e segunda rodada do Claude com ele ([resultado](teste-dom-casmurro.md#rodada-2-prompt-v2))
- [x] Formato da memória com lista única de personagens ([formato](formato-memoria.md))
- [x] Documentação inicial

## 1. "Quem é esse?" sem IA

A primeira função, sem depender de nada externo.

- [ ] Esqueleto do plugin (`_meta.lua`, `main.lua`, menu, tradução pt-BR)
- [ ] "Quem é esse?" no menu de seleção de texto
- [ ] Busca da primeira aparição e das últimas menções até a posição atual
- [ ] Tela de resultado com toque para ir até a menção e voltar
- [ ] Testar no Kindle 10ª geração: tempo de busca num livro de 1.000 páginas

## 2. Memória direto no Kindle

- [ ] Conversão de posição do KOReader para (fragmento, palavra)
- [ ] Divisão em blocos no Kindle
- [ ] Gravar e ler o `memoria.json` na pasta `.sdr`
- [ ] Serviço de IA: Claude primeiro, com interface comum para os outros
- [ ] Geração aos poucos, à frente da leitura, só com Wi-Fi e bateria suficiente
- [x] Prompt v3 para o modo aos poucos, já no formato da lista única de personagens ([prompt](../prompts/memoria-aos-poucos.md))
- [ ] Checagem de spoiler de nomes e de limites de palavras, com nova tentativa só do que falhou
- [ ] Testar o prompt v3: rodar o modo aos poucos com *Dom Casmurro* e comparar com as rodadas do livro inteiro

## 3. Telas que usam a memória

- [ ] "Quem é esse?" com ficha do personagem
- [ ] Previamente em…
- [ ] X-Ray do capítulo
- [ ] Onde você parou

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
