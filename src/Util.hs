module Util where

import Yesod
import Control.Monad (unless)
import Data.Text (Text)
import qualified Data.Text as T
import Database.Persist.Sql (SqlBackend)
import Network.HTTP.Types (Status, status400, status409)
import Foundation


responderErro :: Status -> Text -> Handler a
responderErro status mensagem = sendStatusJSON status (object ["erro" .= mensagem])


validar :: Bool -> Text -> Handler ()
validar condicao mensagem = unless condicao (responderErro status400 mensagem)


verificarConflito :: Bool -> Text -> Handler ()
verificarConflito condicao mensagem = unless condicao (responderErro status409 mensagem)


mensagem :: Text -> Value
mensagem texto = object ["mensagem" .= texto]


textoVazio :: Text -> Bool
textoVazio texto = T.null (T.strip texto)


buscarOuFalhar :: PersistRecordBackend registro SqlBackend
               => Key registro -> Text -> Handler registro
buscarOuFalhar chave mensagemErro = do
    resultado <- runDB (get chave)
    case resultado of
        Just registro -> return registro
        Nothing       -> responderErro status400 mensagemErro
