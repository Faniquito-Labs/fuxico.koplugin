# Fuxico

> Todo o fuxico do livro até onde você leu: quem é quem, o que rolou e onde você parou.
>
> O livro guarda o texto. O Kindle lembra a história por você.

Fuxico é um plugin para o [KOReader](https://github.com/koreader/koreader) que ajuda a retomar a leitura sem se perder: quem é esse personagem, o que aconteceu até aqui, onde você parou. Tudo sem spoiler, porque a memória só vai até o ponto em que você está.

Feito em português do Brasil, para livros em português.

**Situação:** etapa 1 em andamento. O "Quem é esse?" sem IA funciona no KOReader do computador; falta testar num Kindle. Veja o [roteiro](docs/roteiro.md).

## Instalar (para testar)

1. Baixe o repositório e renomeie a pasta para `fuxico.koplugin`.
2. Copie a pasta para `koreader/plugins/` no Kindle (ou no aparelho em que o KOReader estiver).
3. Reinicie o KOReader e deixe a interface em **Settings › Language › Português (Brasil)**.
4. Num livro EPUB, segure o dedo num nome e toque em **Quem é esse?**. As opções ficam em **Ferramentas › Fuxico**.

## Desenvolvimento

- Testes (precisa do pacote `lupa`): `python3 -m venv .venv && .venv/bin/pip install lupa`, depois `.venv/bin/python -I ferramentas/testes/testar.py`.
- Teste dentro do KOReader do computador (Mac ou Linux): `ferramentas/testes/koreader/rodar.sh <pasta koreader do KOReader> <pasta de saída>`. Gera um livro de teste, abre o KOReader com o plugin, passa pelas telas do "Quem é esse?" e salva uma foto de cada uma na pasta de saída. No Mac, a pasta do KOReader fica em `KOReader.app/Contents/koreader` (as versões para Mac saem na release `ota` do KOReader).
- Traduções: depois de mudar textos no código, `python3 -I ferramentas/l10n/extrair.py`, atualize `l10n/pt_BR/fuxico.po` e rode `python3 -I ferramentas/l10n/compilar.py`.

## O que ele vai fazer

| Função | Com memória | Sem memória (sem IA) |
|---|---|---|
| **Quem é esse?** (segurar o dedo num nome) | Ficha do personagem até o ponto atual, com apelidos | Primeira aparição e últimas menções do nome até a página atual |
| **O que rolou?** | Resumo do que aconteceu até aqui, na medida do tempo parado | O trecho de antes da página e os nomes mais citados |
| **Quem tá na cena?** | Personagens do trecho, com descrição | Nomes próprios mais citados no capítulo |
| **Onde eu parei?** | Onde você está no capítulo, quanto falta, resumo do trecho e suas últimas paradas | O mesmo, com o começo do capítulo no lugar do resumo |

Detalhes em [docs/funcoes.md](docs/funcoes.md).

## Como funciona, em uma frase

A memória do livro é gerada uma vez por uma IA, bloco a bloco, e fica salva num arquivo `memoria.json` ao lado do livro. Durante a leitura, o plugin só lê esse arquivo, sem internet.

Há dois jeitos de gerar a memória:

- **Direto no Kindle, com IA na nuvem.** O plugin gera a memória dos próximos capítulos, à frente da leitura, com pedidos pequenos. Precisa de Wi-Fi e de uma chave de API.
- **No PC, com IA local.** Um processador gera a memória quando o livro entra no Calibre, e ela vai para o Kindle junto com o livro. Nada sai de casa.

Sem nenhum dos dois, o plugin funciona no **modo sem IA**, só com buscas no texto do próprio livro.

Arquitetura completa em [docs/arquitetura.md](docs/arquitetura.md).

## Documentação

- [Funções](docs/funcoes.md): o que cada tela mostra, com e sem memória
- [Design](docs/design.md): princípios visuais para e-ink e as peças de tela (gaveta, cartões, linha do tempo)
- [Arquitetura](docs/arquitetura.md): modos de geração, onde os arquivos ficam, como o plugin conversa com o KOReader
- [Formato da memória](docs/formato-memoria.md): o `memoria.json`, posição no texto e a chave do livro
- [Base compartilhada](docs/base-compartilhada.md): ideia de um servidor com memórias prontas, direito autoral e privacidade
- [Teste com Dom Casmurro](docs/teste-dom-casmurro.md): comparação entre IAs que definiu o prompt
- Prompts enviados à IA: [aos poucos (v3.3, padrão)](prompts/memoria-aos-poucos.md) e [livro inteiro (v2)](prompts/memoria-livro-inteiro.md)
- [Roteiro](docs/roteiro.md): as etapas, da primeira função ao acabamento

## Privacidade

- O texto do livro só sai do Kindle (ou do PC) quando você escolhe gerar a memória com uma IA na nuvem, e vai direto para o serviço que você configurou.
- O modo sem IA e o modo PC com IA local não mandam nada para fora.
- A chave de API fica só no Kindle.
- O plugin não tem conta, login nem telemetria.

## Aparelho de referência

Kindle básico de 10ª geração (2019): 512 MB de RAM, processador de 1 GHz, tela de 167 ppi. Se funcionar bem nele, funciona nos outros.

## Licença

O código é distribuído sob a [GNU Affero General Public License v3.0](LICENSE) (AGPL-3.0), a mesma do KOReader. Você pode usar, estudar, modificar e distribuir; versões modificadas, inclusive as oferecidas como serviço pela internet, precisam ter o código aberto sob a mesma licença.

As memórias geradas (resumos e fichas) não são código e terão licença própria quando a base compartilhada existir.
