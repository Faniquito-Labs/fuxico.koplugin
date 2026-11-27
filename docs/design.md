# Design

Como o Fuxico aparece na tela. As decisões abaixo saíram das rodadas de mockup de 27/11/2026; o comportamento de cada função está em [funcoes.md](funcoes.md).

## Princípios

1. **Feito para e-ink.** Só preto, branco e cinza. Bordas grossas, sem sombra, degradê nem animação: no e-ink isso vira borrão e deixa a tela lenta.
2. **Alvos grandes.** Botões e cartões grandes, porque o toque no Kindle é menos preciso que no celular.
3. **De onde veio cada informação, sem legenda.** O que a IA escreveu fica num **cartão invertido** (fundo preto, texto branco, ícone ✦). Trechos do próprio livro ficam em **cartões de borda**. Os dois nunca se misturam no mesmo cartão.
4. **Nada vazio.** Sem quadro reservado do tipo "vai aparecer aqui". Se uma informação não existe (por exemplo, o livro não tem memória), a seção simplesmente não aparece.
5. **Nada depois da posição atual.** Contagens, linhas do tempo e listas param no ponto em que você está. O que vem depois aparece tracejado, sem marcas, para não entregar quantas vezes alguém ainda vai aparecer.
6. **Textos neutros sem memória.** Sem IA, o plugin não sabe se um nome é pessoa ou lugar, então usa palavras neutras: "menções", "primeira aparição", "sumiu por". Com memória, a IA classifica e a tela mostra o tipo.
7. **Frases inteiras.** Os trechos mostram a frase completa em que o nome aparece, não pedaços de cinco palavras com reticências.

## Peças visuais

### Gaveta

A tela principal do Fuxico é uma **gaveta** que sobe da parte de baixo da tela, por cima da página, que continua visível em cima. Tem cantos arredondados no topo e uma alça. A mesma gaveta serve depois para as outras funções.

### Tela completa

Quando a gaveta não basta (todas as menções, histórico da ficha), abre uma tela cheia com título, botão de voltar e fechar, filtros em pílulas e cartões.

### Linha do tempo de aparições

Uma barra do livro inteiro com um tracinho em cada menção, só até a posição atual, e um marcador de "você está aqui". Aparece em miniatura na gaveta e grande na tela completa.

### Menu de configurações

Fica no **menu nativo do KOReader** (Ferramentas › Fuxico), não em tela própria: é aberto raramente, e o menu nativo já tem caixinhas de marcar, escolha de números, campo de texto e segue o tamanho de fonte do aparelho. Detalhes em [funcoes.md](funcoes.md#configurações).

## Cartão escuro e e-ink

Áreas grandes de preto podem deixar "fantasma" quando a tela muda. O cartão da IA é pequeno e a gaveta pede atualização completa da tela ao abrir, então não deve ser problema. Se for no Kindle de 10ª geração, o cartão vira um cartão de borda grossa com o ícone ✦.
