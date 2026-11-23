module Handler.Cep where

import Yesod
import Data.Text (Text)
import Network.HTTP.Types (status404)
import Foundation
import Util
import ViaCep

getCepR :: Text -> Handler Value
getCepR cep = do
    resultado <- liftIO (buscarCep cep)
    case resultado of
        Just endereco -> returnJson endereco
        Nothing       -> responderErro status404 "CEP invalido ou nao encontrado"
