# Funções

Cada função tem duas versões: **com memória**, quando o livro tem um `memoria.json`, e **sem IA**, quando não tem (nenhuma IA configurada, sem Wi-Fi ou livro ainda não processado). O modo sem IA nunca escreve resumo; ele só mostra trechos do próprio livro, que nunca saem do Kindle.

As funções têm nome de **pergunta que o leitor faz**: "Quem é esse?", "O que rolou?", "Quem tá na cena?" e "Onde eu parei?".

Em todas elas, a regra é a mesma: **nada depois da posição atual de leitura**. A exceção é o modo releitura (ver [Memória deste livro](#memória-deste-livro)).

O visual de cada tela segue os princípios de [design.md](design.md).

## Quem é esse?

### Como abre

Segurando o dedo sobre um nome, aparece o menu de seleção de sempre do KOReader (Destacar, Copiar, Dicionário, Buscar...). O Fuxico acrescenta um botão **"Quem é esse?"** nesse menu. Tocar nele abre a gaveta.

### Proteção: só em nomes próprios

Duas camadas, para o botão não aparecer em palavras comuns:

1. **Antes de mostrar o botão (instantânea).** O botão só aparece se a seleção parecer um nome:
   - começa com maiúscula, inclusive acentuada ("Ângela", "Élio");
   - em nomes compostos, cada palavra começa com maiúscula, menos as ligações (de, da, do, dos, das, e): "José Dias", "Rio de Janeiro", "Ezequiel de Sousa Escobar";
   - palavras de 1 ou 2 letras e uma lista fixa de palavras comuns que costumam abrir frases (Ele, Ela, Quando, Então, Senhor...) não contam.
2. **Depois da busca (a prova real).** A busca já acontece de qualquer jeito, então o plugin confere as ocorrências **no meio da frase**, onde a maiúscula não é obrigatória:
   - quase sempre com maiúscula: é nome próprio, e a gaveta abre normal;
   - aparece com minúscula: é palavra comum que estava no começo de uma frase. A gaveta mostra **"Não parece ser um nome"**, com atalhos para **Dicionário** e **Buscar**, e um "Mostrar mesmo assim" discreto.

Títulos de capítulo em MAIÚSCULAS não contam na conferência. A proteção pode ser desligada em "Só em nomes próprios", para livros que escrevem nomes em minúscula de propósito.

A mesma regra vale para **lugares e nomes de coisas** ("Matacavalos", "Engenho Novo", "Seminário de São José"). Sem memória, os textos são neutros e não chamam lugar de personagem.

### Gaveta sem memória

De cima para baixo:

1. **Nome** em destaque. Sem avatar nem inicial.
2. **Linha de resumo:** número de menções, desde que capítulo e até que página ("27 menções · desde o cap. III · até a pág. 71").
3. **Aviso de sumiço**, só quando a menção anterior está longe (padrão: 30 páginas): "Sumiu por 58 páginas. Última vez no cap. LXXI."
4. **Miniatura da linha do tempo** de aparições, só até a posição atual.
5. **"Antes desta, a última vez":** a frase da menção anterior, com capítulo e distância ("há 1 página"). Vem primeiro porque o "quem é esse?" costuma acontecer quando o personagem volta depois de sumir.
6. **"Primeira aparição":** a frase, com capítulo.
7. Botão **"Ver as N menções"**, que abre a tela completa.
8. Se uma IA estiver configurada: um convite discreto **"Gerar a memória deste livro"**.

Os cartões de trecho são tocáveis: levam ao trecho no livro, guardando a posição atual para o "voltar" nativo do KOReader.

### Gaveta com memória

1. **Nome**, com o **tipo** ("pessoa", "lugar") ao lado.
2. **Linha de resumo**, com os **apelidos** conhecidos até aqui ("também: Capitolina · 27 menções · até a pág. 71").
3. **Ficha** no cartão invertido, com o título "Quem é, até aqui" e o texto mais recente da IA. No rodapé:
   - "Atualizada no cap. XXXI": quando a ficha mudou pela última vez. Se for antiga em relação à posição atual, o personagem passou muito tempo sem novidade;
   - "primeira vez no cap. III";
   - "Aparece mais com: Bentinho, José Dias": os personagens que mais dividem trechos com ele até aqui, calculados da lista `presentes` dos blocos, sem chamada extra à IA.
   
   O ícone de relógio no cartão abre o **histórico da ficha**: como ela mudou ao longo do livro, só até onde você leu.
4. Aviso de sumiço, miniatura da linha do tempo e "Antes desta, a última vez", como na versão sem memória.
5. Botão "Ver as N menções".

A primeira aparição sai da gaveta e fica só na tela completa, porque a ficha já explica quem é.

Se o nome não estiver na lista de personagens da memória, a gaveta cai na versão sem memória.

### Tela completa ("Ver as N menções")

- Linha do tempo grande, só até a posição atual, com "você está aqui".
- Filtros em pílulas: **Recentes** ou **Por capítulo**.
- As menções em cartões, com a frase inteira, o capítulo e a distância ("há 2 páginas").
- Opção nas configurações para abrir direto esta tela, em vez da gaveta.

### Para decidir depois

- **"Também se chama…"**: juntar à mão dois nomes da mesma pessoa no modo sem IA ("Capitu" e "Capitolina"), guardado nos dados do livro.

## O que rolou?

*Desenho proposto em 27/11/2026, em discussão.*

O resumo do que aconteceu até aqui, para quem volta ao livro depois de alguns dias.

### Como abre

- **Ao abrir um livro parado**, aparece um **aviso pequeno no topo**: "Faz 9 dias. Quer ver o que rolou?", com um botão "Ver". Ele some sozinho em alguns segundos, e a tela só abre se você tocar.
- **Parada longa** (padrão: mais de 20 dias): a tela abre direto, sem aviso.
- A qualquer momento, pelo menu (Ferramentas › Fuxico › O que rolou?) ou por um gesto. Nada se perde ao fechar: a memória fica no arquivo do livro, então reabrir é instantâneo e funciona sem internet.

### Na medida do tempo parado

O tamanho do resumo acompanha há quanto tempo você não lê aquele livro. Os limites são configuráveis.

- **Parada curta (até 3 dias):** um lembrete rápido na **gaveta**, com "O que rolou?", há quanto tempo, capítulo e percentual; o cartão da IA "Nos últimos capítulos" com os `resumo_do_bloco` dos últimos trechos, num texto só; as pílulas "Quem tá na cena?"; e os botões "Ver tudo" (abre a tela completa) e "Continuar".
- **Parada média (4 a 20 dias):** a **tela completa**, com "A história até aqui" recolhida nas primeiras linhas e "Ler tudo".
- **Parada longa (mais de 20 dias):** a tela completa, com "A história até aqui" já aberta por inteiro e mais trechos em "Nos últimos capítulos".

### Tela completa (com memória)

De cima para baixo:

1. **"O que rolou?"**, o título do livro e uma linha com há quanto tempo, em que capítulo e em que percentual você parou.
2. **"A história até aqui"** no cartão invertido: o `resumo_ate_aqui` do último bloco lido por inteiro.
3. **"Nos últimos capítulos":** os `resumo_do_bloco` dos últimos blocos, numa linha do tempo vertical, marcando o trecho em que você está.
4. **"Quem tá na cena?":** pílulas com os personagens `presentes` no bloco atual. Tocar num nome abre a gaveta do "Quem é esse?".
5. **"Logo antes desta página":** os parágrafos da página anterior à atual, como trecho do livro. Não mostra a página atual, que você vai ver ao voltar; mostra o gancho da cena, que você não vê.
6. Botão **"Continuar lendo"**.

### Sem IA

Enxuta, só com o que dá para tirar do texto:

1. O mesmo cabeçalho (título, há quanto tempo, capítulo, percentual).
2. **"Logo antes desta página":** um trecho maior antes da posição atual.
3. **"Mais citados nos últimos capítulos":** pílulas com os nomes próprios mais frequentes, com a contagem, tocáveis como as de "Quem tá na cena?".
4. Com uma IA configurada, um convite para gerar a memória.
5. Botão "Continuar lendo".

## Quem tá na cena?

Quem aparece no trecho em que você está, o antigo "X-Ray do capítulo".


**Como abre:** menu do plugin, um gesto ou um toque no canto da tela (configurável).

**Com memória:** lista os personagens presentes no bloco atual, com a ficha mais recente de cada um.

**Sem IA:** detecta palavras com letra maiúscula no meio da frase, do início do capítulo até a posição atual, e lista as mais frequentes, com a mesma proteção do "Quem é esse?".

## Onde eu parei?

**Como abre:** ao abrir o livro (configurável), pelo menu ou por um gesto.

**Com memória:** o `resumo_do_bloco` do trecho em que você está, mais a posição em capítulo e percentual.

**Sem IA:** o último parágrafo lido antes de fechar o livro.

## Configurações

Ficam no menu nativo do KOReader, em **Ferramentas › Fuxico**, organizadas **por função**. Cada item mostra o estado atual numa linha embaixo, para não precisar entrar nele.

### Memória deste livro

A única seção que vale só para o livro aberto.
- Estado: quantos trechos estão prontos e até que capítulo ("32 de 61 trechos prontos · até o cap. XL"), ou o progresso quando está gerando.
- Gerar agora.
- Gerar à frente: quantos capítulos adiante (1, 2 ou 5).
- **Modo releitura:** libera o livro inteiro só neste livro, para quem já sabe o final.
- **Desligar o Fuxico neste livro:** o botão some do menu de seleção só neste livro (não ficção, contos, livros técnicos). PDFs já ficam de fora.
- **Exportar e importar a memória:** copiar o `memoria.json` para uma pasta e trazer de outra (backup, outro aparelho, base compartilhada).
- Apagar a memória deste livro.

### Quem é esse?

- Só em nomes próprios (ligado).
- Avisar quando sumiu por: 30 páginas.
- Mostrar a miniatura da linha do tempo (ligado).
- Abrir direto a tela completa (desligado).

### O que rolou?

- Avisar ao abrir um livro parado há mais de: desligado, 1, 3 ou 7 dias.
- Parada curta até: 3 dias. Parada longa a partir de: 20 dias (abre direto, sem aviso).
- Ligar a um gesto (explica o caminho no Gerenciador de gestos do KOReader).

### Quem tá na cena?

- Ligar a um gesto ou a um canto da tela.

### Onde eu parei?

- Abrir ao retomar a leitura (desligado).

### Inteligência artificial

- Modo: nenhum (só sem IA), nuvem ou PC.
- Serviço: Gemini, Claude, DeepSeek ou Groq.
- Chave de API, mostrada mascarada (só os 4 últimos caracteres).
- **Importar chave de arquivo:** lê um `fuxico-chave.txt` copiado pelo USB para a raiz do Kindle e apaga o arquivo depois de importar.
- Testar conexão.
- Quando gerar: só no Wi-Fi, e **só carregando** ou com **bateria mínima** (padrão: 30%).
- **Uso:** "Este mês: 38 trechos gerados", e um **limite mensal** opcional para os serviços pagos.

### Sobre e privacidade

- Versão e link do repositório.
- Em poucas linhas, o que sai do Kindle e quando.

### O menu cresce com o plugin

O menu só mostra opções que já funcionam:
- **Etapa 1:** Quem é esse? e Sobre e privacidade.
- **Etapa 2:** entram Memória deste livro e Inteligência artificial.
- **Etapa 3:** entram O que rolou?, Quem tá na cena? e Onde eu parei?.

### Onde ficam guardadas

- Configurações gerais e chave de API: num arquivo próprio do plugin, na pasta de configurações do KOReader, só no Kindle.
- Configurações por livro (releitura, desligado neste livro) e a memória: na pasta `.sdr` do livro.
