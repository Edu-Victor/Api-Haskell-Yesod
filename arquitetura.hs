--Endpoint home

-- | GET /    retorna o nome da API e a lista de rotas


--Endpoint autor

-- | GET /autores
-- | POST /autores   corpo: {"nome": "Machado de Assis", "nacionalidade": "Brasileira"}
-- | GET /autores/#AutorId
-- | PUT /autores/#AutorId   corpo: igual ao do POST
-- | DELETE /autores/#AutorId


--Endpoint editora

-- | GET /editoras
-- | POST /editoras   corpo: {"nome": "Companhia das Letras", "cidade": "Sao Paulo"}
-- | GET /editoras/#EditoraId
-- | PUT /editoras/#EditoraId   corpo: igual ao do POST
-- | DELETE /editoras/#EditoraId


--Endpoint categoria

-- | GET /categorias
-- | POST /categorias   corpo: {"nome": "Romance"}
-- | GET /categorias/#CategoriaId
-- | PUT /categorias/#CategoriaId   corpo: igual ao do POST
-- | DELETE /categorias/#CategoriaId


--Endpoint livro

-- | GET /livros
-- | POST /livros   corpo: {"titulo": "Dom Casmurro", "ano": 1899, "quantidade": 3, "autorId": 1, "editoraId": 1, "categoriaId": 1}
-- | GET /livros/#LivroId
-- | PUT /livros/#LivroId   corpo: igual ao do POST
-- | DELETE /livros/#LivroId
-- | GET /livros/#LivroId/avaliacoes


--Endpoint leitor

-- | GET /leitores
-- | POST /leitores   corpo: {"nome": "Joao Silva", "email": "joao@email.com", "cep": "01001000"}
-- | GET /leitores/#LeitorId
-- | PUT /leitores/#LeitorId   corpo: igual ao do POST
-- | DELETE /leitores/#LeitorId


--Endpoint emprestimo

-- | GET /emprestimos
-- | POST /emprestimos   corpo: {"livroId": 1, "leitorId": 1}
-- | GET /emprestimos/#EmprestimoId
-- | PUT /emprestimos/#EmprestimoId/devolucao   sem corpo
-- | DELETE /emprestimos/#EmprestimoId


--Endpoint avaliacao

-- | GET /avaliacoes
-- | POST /avaliacoes   corpo: {"livroId": 1, "leitorId": 1, "nota": 5, "comentario": "Otimo livro"}
-- | GET /avaliacoes/#AvaliacaoId
-- | PUT /avaliacoes/#AvaliacaoId   corpo: igual ao do POST
-- | DELETE /avaliacoes/#AvaliacaoId


--Endpoint cep

-- | GET /cep/#cep   exemplo: /cep/01001000