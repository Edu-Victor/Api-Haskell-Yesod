# Biblioteca API

API REST para gerenciamento de uma biblioteca: cadastro de autores, editoras, categorias, livros e leitores, controle de empréstimos/devoluções e avaliações de livros. O endereço dos leitores é preenchido automaticamente pela API externa **ViaCEP**.

Arquitetura escolhida: **Opção B – Backend Yesod + Postman** (somente API, testada pelo Postman).

## Tecnologias

- Haskell (GHC 9.10) + **Yesod** (framework web)
- **Persistent** (ORM) + **PostgreSQL**
- http-conduit (cliente HTTP para o ViaCEP)
- Stack (build) e Postman (testes)
- Docker + Render (hospedagem) e PostgreSQL gerenciado na DigitalOcean

## Como executar

1. Ter instalado: Stack e PostgreSQL 18.
2. Criar o banco `haskell` (usuário `postgres`, senha `1234`). As tabelas são criadas sozinhas ao iniciar.
   A conexão fica em `src/Main.hs` (`conexao`).
3. **Somente no Windows, uma vez:** instalar a biblioteca `libpq` no MSYS2 do Stack (o driver do Postgres precisa dela para compilar):
   ```powershell
   stack exec -- pacman -S --noconfirm mingw-w64-clang-x86_64-postgresql mingw-w64-clang-x86_64-pkgconf
   ```
4. Compilar e rodar (a primeira compilação demora, pois baixa as bibliotecas):
   ```powershell
   stack build
   stack run
   ```
5. A API sobe em `http://localhost:3000`. Importe `postman_collection.json` no Postman.

### Variáveis de ambiente

A conexão com o banco e a porta vêm de variáveis de ambiente. Todas as variáveis `DB_*` são obrigatórias: se alguma não estiver definida, a aplicação não inicia.

| Variável | Descrição |
|---|---|
| `DB_HOST` | Endereço do servidor do banco |
| `DB_PORT` | Porta do banco |
| `DB_USER` | Usuário do banco |
| `DB_PASSWORD` | Senha do banco |
| `DB_NAME` | Nome do banco de dados |
| `DB_SSLMODE` | Modo de conexão SSL (`require` em produção) |
| `PORT` | Porta em que a API escuta (o Render define sozinho) |

## Deploy (Render + Docker + PostgreSQL na DigitalOcean)

1. Suba o código para o GitHub.
2. No Render: **New → Web Service** → escolha o repositório → **Language: Docker** (ele usa o `Dockerfile`).
3. Em **Environment**, cadastre as variáveis `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` e `DB_SSLMODE=require`.
4. **Deploy**. A primeira compilação é demorada (as bibliotecas do Yesod são compiladas dentro do Docker).
5. As tabelas são criadas automaticamente no banco da DigitalOcean quando a aplicação inicia.
6. No Postman, troque a variável `baseUrl` da coleção para a URL do Render (ex.: `https://biblioteca-api.onrender.com`).

> Na DigitalOcean, se o banco tiver **Trusted Sources** ativado, é preciso liberar o acesso do Render (ou desativar a restrição), senão a conexão é recusada.

## Organização do código

| Arquivo | Função |
|---|---|
| `src/Main.hs` | Conecta no banco, roda a migração e sobe o servidor |
| `src/Foundation.hs` | Tipo `App`, **rotas** e configuração do Yesod/banco |
| `src/Models.hs` | **Tabelas** do banco (Persistent) |
| `src/Util.hs` | Funções de erro e validação reaproveitadas |
| `src/ViaCep.hs` | Integração com a API ViaCEP |
| `src/Handler/*.hs` | Um arquivo por entidade com o CRUD |

## Banco de dados (7 tabelas)

| Tabela | Descrição | Chaves estrangeiras |
|---|---|---|
| `autor` | Autores dos livros | – |
| `editora` | Editoras | – |
| `categoria` | Categorias (nome único) | – |
| `livro` | Livros e quantidade de exemplares disponíveis | autor, editora, categoria |
| `leitor` | Leitores com endereço vindo do ViaCEP (e-mail único) | – |
| `emprestimo` | Empréstimo de um livro para um leitor, com data de devolução | livro, leitor |
| `avaliacao` | Nota (1 a 5) e comentário de um leitor sobre um livro | livro, leitor |

## Integração com API externa

**ViaCEP** (`https://viacep.com.br/ws/{cep}/json/`). Ao cadastrar ou alterar um leitor, o cliente envia apenas `nome`, `email` e `cep`; o servidor consulta o ViaCEP e **grava** logradouro, bairro, cidade e UF na tabela `leitor`. CEP inválido retorna erro 400. A rota `GET /cep/{cep}` permite consultar um CEP diretamente.

## Endpoints

Todas as entidades seguem o padrão: `GET /recurso` (listar), `POST /recurso` (criar), `GET /recurso/{id}` (buscar), `PUT /recurso/{id}` (alterar), `DELETE /recurso/{id}` (excluir).

| Método | Rota | Finalidade / corpo de exemplo |
|---|---|---|
| GET | `/` | Informações da API |
| GET, POST | `/autores` | `{"nome": "Machado de Assis", "nacionalidade": "Brasileira"}` |
| GET, PUT, DELETE | `/autores/{id}` | |
| GET, POST | `/editoras` | `{"nome": "Companhia das Letras", "cidade": "São Paulo"}` |
| GET, PUT, DELETE | `/editoras/{id}` | |
| GET, POST | `/categorias` | `{"nome": "Romance"}` |
| GET, PUT, DELETE | `/categorias/{id}` | |
| GET, POST | `/livros` | `{"titulo": "Dom Casmurro", "ano": 1899, "quantidade": 2, "autorId": 1, "editoraId": 1, "categoriaId": 1}` |
| GET, PUT, DELETE | `/livros/{id}` | |
| GET | `/livros/{id}/avaliacoes` | Avaliações de um livro |
| GET, POST | `/leitores` | `{"nome": "Maria", "email": "maria@email.com", "cep": "01001-000"}` |
| GET, PUT, DELETE | `/leitores/{id}` | |
| GET, POST | `/emprestimos` | `{"livroId": 1, "leitorId": 1}` (diminui a quantidade do livro) |
| GET, DELETE | `/emprestimos/{id}` | |
| PUT | `/emprestimos/{id}/devolucao` | Registra a devolução (devolve o exemplar) |
| GET, POST | `/avaliacoes` | `{"livroId": 1, "leitorId": 1, "nota": 5, "comentario": "Ótimo"}` |
| GET, PUT, DELETE | `/avaliacoes/{id}` | |
| GET | `/cep/{cep}` | Consulta direta ao ViaCEP |

Códigos de resposta: `200` OK, `201` criado, `400` dados inválidos, `404` não encontrado, `409` conflito (ex.: excluir autor que tem livros, e-mail repetido). Erros vêm no formato `{"erro": "mensagem"}`.

## Integrantes

- Nome – principais contribuições
