module Handler.Categoria where

import Yesod
import Network.HTTP.Types (status201, status409)
import Foundation
import Models
import Util


getCategoriasR :: Handler Value
getCategoriasR = do
    categorias <- runDB (selectList [] [Asc CategoriaNome])
    returnJson categorias


postCategoriasR :: Handler Value
postCategoriasR = do
    categoria <- requireCheckJsonBody :: Handler Categoria
    validarCategoria categoria
  
    resultado <- runDB (insertUnique categoria)
    case resultado of
        Nothing          -> responderErro status409 "Ja existe uma categoria com este nome"
        Just categoriaId -> sendStatusJSON status201 (Entity categoriaId categoria)


getCategoriaR :: CategoriaId -> Handler Value
getCategoriaR categoriaId = do
    categoria <- runDB (get404 categoriaId)
    returnJson (Entity categoriaId categoria)


putCategoriaR :: CategoriaId -> Handler Value
putCategoriaR categoriaId = do
    _ <- runDB (get404 categoriaId)
    categoria <- requireCheckJsonBody :: Handler Categoria
    validarCategoria categoria
    
    mesmoNome <- runDB (getBy (UniqueCategoriaNome (categoriaNome categoria)))
    case mesmoNome of
        Just (Entity outroId _) | outroId /= categoriaId ->
            responderErro status409 "Ja existe uma categoria com este nome"
        _ -> return ()
    runDB (replace categoriaId categoria)
    returnJson (Entity categoriaId categoria)


deleteCategoriaR :: CategoriaId -> Handler Value
deleteCategoriaR categoriaId = do
    _ <- runDB (get404 categoriaId)
    qtdLivros <- runDB (count [LivroCategoriaId ==. categoriaId])
    verificarConflito (qtdLivros == 0) "Nao e possivel excluir: existem livros nesta categoria"
    runDB (delete categoriaId)
    returnJson (mensagem "Categoria excluida com sucesso")

validarCategoria :: Categoria -> Handler ()
validarCategoria categoria =
    validar (not (textoVazio (categoriaNome categoria))) "O nome da categoria e obrigatorio"
