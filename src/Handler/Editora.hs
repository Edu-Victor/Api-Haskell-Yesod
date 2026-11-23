module Handler.Editora where

import Yesod
import Network.HTTP.Types (status201)
import Foundation
import Models
import Util


getEditorasR :: Handler Value
getEditorasR = do
    editoras <- runDB (selectList [] [Asc EditoraId])
    returnJson editoras


postEditorasR :: Handler Value
postEditorasR = do
    editora <- requireCheckJsonBody :: Handler Editora
    validarEditora editora
    editoraId <- runDB (insert editora)
    sendStatusJSON status201 (Entity editoraId editora)


getEditoraR :: EditoraId -> Handler Value
getEditoraR editoraId = do
    editora <- runDB (get404 editoraId)
    returnJson (Entity editoraId editora)


putEditoraR :: EditoraId -> Handler Value
putEditoraR editoraId = do
    _ <- runDB (get404 editoraId)
    editora <- requireCheckJsonBody :: Handler Editora
    validarEditora editora
    runDB (replace editoraId editora)
    returnJson (Entity editoraId editora)


deleteEditoraR :: EditoraId -> Handler Value
deleteEditoraR editoraId = do
    _ <- runDB (get404 editoraId)
    qtdLivros <- runDB (count [LivroEditoraId ==. editoraId])
    verificarConflito (qtdLivros == 0) "Nao e possivel excluir: existem livros desta editora"
    runDB (delete editoraId)
    returnJson (mensagem "Editora excluida com sucesso")

validarEditora :: Editora -> Handler ()
validarEditora editora =
    validar (not (textoVazio (editoraNome editora))) "O nome da editora e obrigatorio"
