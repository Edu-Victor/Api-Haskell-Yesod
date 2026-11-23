module Handler.Livro where

import Yesod
import Network.HTTP.Types (status201)
import Foundation
import Models
import Util


getLivrosR :: Handler Value
getLivrosR = do
    livros <- runDB (selectList [] [Asc LivroTitulo])
    returnJson livros


postLivrosR :: Handler Value
postLivrosR = do
    livro <- requireCheckJsonBody :: Handler Livro
    validarLivro livro
    livroId <- runDB (insert livro)
    sendStatusJSON status201 (Entity livroId livro)


getLivroR :: LivroId -> Handler Value
getLivroR livroId = do
    livro <- runDB (get404 livroId)
    returnJson (Entity livroId livro)

putLivroR :: LivroId -> Handler Value
putLivroR livroId = do
    _ <- runDB (get404 livroId)
    livro <- requireCheckJsonBody :: Handler Livro
    validarLivro livro
    runDB (replace livroId livro)
    returnJson (Entity livroId livro)


deleteLivroR :: LivroId -> Handler Value
deleteLivroR livroId = do
    _ <- runDB (get404 livroId)
    qtdEmprestimos <- runDB (count [EmprestimoLivroId ==. livroId])
    qtdAvaliacoes  <- runDB (count [AvaliacaoLivroId ==. livroId])
    verificarConflito (qtdEmprestimos == 0 && qtdAvaliacoes == 0)
        "Nao e possivel excluir: o livro possui emprestimos ou avaliacoes"
    runDB (delete livroId)
    returnJson (mensagem "Livro excluido com sucesso")


getLivroAvaliacoesR :: LivroId -> Handler Value
getLivroAvaliacoesR livroId = do
    _ <- runDB (get404 livroId)
    avaliacoes <- runDB (selectList [AvaliacaoLivroId ==. livroId] [Desc AvaliacaoNota])
    returnJson avaliacoes


validarLivro :: Livro -> Handler ()
validarLivro livro = do
    validar (not (textoVazio (livroTitulo livro))) "O titulo do livro e obrigatorio"
    validar (livroAno livro > 0) "O ano deve ser maior que zero"
    validar (livroQuantidade livro >= 0) "A quantidade nao pode ser negativa"

    _ <- buscarOuFalhar (livroAutorId livro)     "Autor informado nao existe"
    _ <- buscarOuFalhar (livroEditoraId livro)   "Editora informada nao existe"
    _ <- buscarOuFalhar (livroCategoriaId livro) "Categoria informada nao existe"
    return ()
