module Handler.Autor where

import Yesod
import Network.HTTP.Types (status201)
import Foundation
import Models
import Util

getAutoresR :: Handler Value
getAutoresR = do
    autores <- runDB (selectList [] [Asc AutorId])
    returnJson autores


postAutoresR :: Handler Value
postAutoresR = do
    autor <- requireCheckJsonBody :: Handler Autor
    validarAutor autor
    autorId <- runDB (insert autor)
    sendStatusJSON status201 (Entity autorId autor)


getAutorR :: AutorId -> Handler Value
getAutorR autorId = do
    autor <- runDB (get404 autorId)
    returnJson (Entity autorId autor)


putAutorR :: AutorId -> Handler Value
putAutorR autorId = do
    _ <- runDB (get404 autorId)
    autor <- requireCheckJsonBody :: Handler Autor
    validarAutor autor
    runDB (replace autorId autor)
    returnJson (Entity autorId autor)


deleteAutorR :: AutorId -> Handler Value
deleteAutorR autorId = do
    _ <- runDB (get404 autorId)
    qtdLivros <- runDB (count [LivroAutorId ==. autorId])
    verificarConflito (qtdLivros == 0) "Nao e possivel excluir: existem livros deste autor"
    runDB (delete autorId)
    returnJson (mensagem "Autor excluido com sucesso")


validarAutor :: Autor -> Handler ()
validarAutor autor =
    validar (not (textoVazio (autorNome autor))) "O nome do autor e obrigatorio"
