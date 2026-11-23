module Models where

import Data.Text (Text)
import Data.Time (Day)
import Database.Persist.TH



share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|


-- 1) Autores dos livros
Autor json
    nome          Text
    nacionalidade Text Maybe

-- 2) Editoras que publicam os livros
Editora json
    nome   Text
    cidade Text Maybe

-- 3) Categorias (Romance, Tecnologia, ...). O nome nao pode repetir.
Categoria json
    nome Text
    UniqueCategoriaNome nome

-- 4) Livros. Cada livro pertence a um autor, uma editora e uma categoria.
--    "quantidade" = exemplares disponiveis para emprestimo.
Livro json
    titulo      Text
    ano         Int
    quantidade  Int
    autorId     AutorId
    editoraId   EditoraId
    categoriaId CategoriaId

-- 5) Leitores (usuarios da biblioteca).
--    O endereco (logradouro, bairro, cidade, uf) e preenchido pela API do ViaCEP.
Leitor json
    nome       Text
    email      Text
    cep        Text
    logradouro Text
    bairro     Text
    cidade     Text
    uf         Text
    UniqueLeitorEmail email

-- 6) Emprestimos: qual leitor pegou qual livro e quando.
--    dataDevolucao fica vazia (Nothing) enquanto o livro nao for devolvido.
Emprestimo json
    livroId        LivroId
    leitorId       LeitorId
    dataEmprestimo Day
    dataDevolucao  Day Maybe

-- 7) Avaliacoes: nota de 1 a 5 que um leitor da para um livro.
Avaliacao json
    livroId    LivroId
    leitorId   LeitorId
    nota       Int
    comentario Text Maybe
|]
