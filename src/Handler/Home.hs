module Handler.Home where

import Yesod
import Data.Text (Text)
import Foundation

getHomeR :: Handler Value
getHomeR = returnJson $ object
    [ "api"    .= ("Biblioteca API - Yesod + PostgreSQL" :: Text)
    , "rotas"  .= ([ "/autores", "/editoras", "/categorias", "/livros"
                   , "/leitores", "/emprestimos", "/avaliacoes", "/cep/{cep}"
                   ] :: [Text])
    ]
