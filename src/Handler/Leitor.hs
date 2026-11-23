module Handler.Leitor where

import Yesod
import Data.Aeson (withObject)
import Data.Text (Text)
import qualified Data.Text as T
import Network.HTTP.Types (status201, status400, status409)
import Foundation
import Models
import Util
import ViaCep


data LeitorEntrada = LeitorEntrada
    { entradaNome  :: Text
    , entradaEmail :: Text
    , entradaCep   :: Text
    }


instance FromJSON LeitorEntrada where
    parseJSON = withObject "LeitorEntrada" $ \obj ->
        LeitorEntrada
            <$> obj .: "nome"
            <*> obj .: "email"
            <*> obj .: "cep"


getLeitoresR :: Handler Value
getLeitoresR = do
    leitores <- runDB (selectList [] [Asc LeitorNome])
    returnJson leitores


postLeitoresR :: Handler Value
postLeitoresR = do
    entrada <- requireCheckJsonBody :: Handler LeitorEntrada
    leitor <- montarLeitor entrada
  
    existente <- runDB (getBy (UniqueLeitorEmail (leitorEmail leitor)))
    case existente of
        Just _  -> responderErro status409 "Ja existe um leitor com este e-mail"
        Nothing -> return ()
    leitorId <- runDB (insert leitor)
    sendStatusJSON status201 (Entity leitorId leitor)


getLeitorR :: LeitorId -> Handler Value
getLeitorR leitorId = do
    leitor <- runDB (get404 leitorId)
    returnJson (Entity leitorId leitor)


putLeitorR :: LeitorId -> Handler Value
putLeitorR leitorId = do
    _ <- runDB (get404 leitorId)
    entrada <- requireCheckJsonBody :: Handler LeitorEntrada
    leitor <- montarLeitor entrada
    existente <- runDB (getBy (UniqueLeitorEmail (leitorEmail leitor)))
    case existente of
        Just (Entity outroId _) | outroId /= leitorId ->
            responderErro status409 "Ja existe outro leitor com este e-mail"
        _ -> return ()
    runDB (replace leitorId leitor)
    returnJson (Entity leitorId leitor)


deleteLeitorR :: LeitorId -> Handler Value
deleteLeitorR leitorId = do
    _ <- runDB (get404 leitorId)
    qtdEmprestimos <- runDB (count [EmprestimoLeitorId ==. leitorId])
    qtdAvaliacoes  <- runDB (count [AvaliacaoLeitorId ==. leitorId])
    verificarConflito (qtdEmprestimos == 0 && qtdAvaliacoes == 0)
        "Nao e possivel excluir: o leitor possui emprestimos ou avaliacoes"
    runDB (delete leitorId)
    returnJson (mensagem "Leitor excluido com sucesso")


montarLeitor :: LeitorEntrada -> Handler Leitor
montarLeitor entrada = do
    validar (not (textoVazio (entradaNome entrada))) "O nome do leitor e obrigatorio"
    validar ("@" `T.isInfixOf` entradaEmail entrada) "E-mail invalido"

    resultado <- liftIO (buscarCep (entradaCep entrada))
    case resultado of
        Nothing -> responderErro status400 "CEP invalido ou nao encontrado no ViaCEP"
        Just endereco -> return Leitor
            { leitorNome       = T.strip (entradaNome entrada)
            , leitorEmail      = T.strip (entradaEmail entrada)
            , leitorCep        = limparCep (entradaCep entrada)
            , leitorLogradouro = enderecoLogradouro endereco
            , leitorBairro     = enderecoBairro endereco
            , leitorCidade     = enderecoCidade endereco
            , leitorUf         = enderecoUf endereco
            }
