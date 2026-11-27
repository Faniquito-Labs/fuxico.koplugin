# Base compartilhada de memórias (futuro)

**Ideia:** quem usa o plugin envia só a memória gerada para um servidor do projeto, e os outros baixam pronta.

**Vantagens:**
- Cada livro passa pela IA uma vez só.
- Quem não tem chave de API também usa.
- A memória tem dezenas de kilobytes e baixa em segundos.

## O que vai e o que não vai

| Vai para o servidor | Nunca sai do Kindle |
|---|---|
| A chave e as impressões do livro | O texto do livro e qualquer trecho dele |
| A memória (resumos curtos e fichas) | Quem é o usuário (sem conta, sem login) |
| A versão do formato | O que ele lê ou onde parou |

## Reconhecer o mesmo livro

ISBN mais as impressões de cada capítulo (ver [formato-memoria.md](formato-memoria.md#chave-do-livro)). Outra tradução ou outra edição conta como outro livro.

## Em quem confiar

| Modelo | Como funciona | Prós e contras |
|---|---|---|
| **Curadoria** | Só o mantenedor publica | Simples e seguro, mas o risco jurídico fica no nome dele |
| **Envio aberto com validação** | O plugin de quem envia roda a checagem de spoiler; a memória só vira oficial quando duas pessoas enviam versões parecidas; qualquer um pode denunciar | Escala, mas exige moderação |

## Direito autoral

- Ideias e fatos não têm proteção (art. 8º da Lei 9.610/98).
- Mas um resumo de cada capítulo do livro inteiro pode parecer uma versão condensada da obra, o que exige autorização (art. 29).

**Para reduzir o risco:**
- Nenhuma citação do livro.
- Resumos curtos.
- Canal de remoção para autores e editoras.
- Começar pelo domínio público.
- Consultar um advogado antes de abrir para livros protegidos.

## Privacidade e custo

- Sem conta nem login. O servidor não guarda IP nem quem baixou o quê (LGPD).
- Custo perto de zero no plano gratuito da Cloudflare (Workers com D1 ou R2).

## Rascunho da API

| Método | Rota | O que faz |
|---|---|---|
| `GET` | `/livros/{chave}` | Memória oficial, se existir |
| `GET` | `/livros?isbn=...` | Edições conhecidas daquele ISBN |
| `POST` | `/memorias` | Envia uma memória (fase 2) |
| `POST` | `/denuncias` | Spoiler, erro ou pedido de remoção |
| `GET` | `/catalogo/dominio-publico` | Lista para baixar tudo de uma vez |

## Fases

1. **Domínio público com curadoria:** Machado de Assis, José de Alencar, Eça de Queirós, Aluísio Azevedo. Vira também a **Estante de Clássicos Brasileiros**: catálogo dentro do KOReader com EPUBs bem formatados e a memória pronta.
2. **Envio aberto**, desligado por padrão, com checagem de spoiler, validação por duas pessoas e denúncia.
3. **Livros com direitos autorais**, só depois de falar com um advogado e com o canal de remoção funcionando.
