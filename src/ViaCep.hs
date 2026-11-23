module ViaCep
    ( Endereco (..)
    , buscarCep
    , limparCep
    ) where

import Control.Exception (try)
import Data.Aeson
import Data.Char (isDigit)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.ByteString.Lazy as BL
import Network.HTTP.Simple

data Endereco = Endereco
    { enderecoCep        :: Text
    , enderecoLogradouro :: Text
    , enderecoBairro     :: Text
    , enderecoCidade     :: Text
    , enderecoUf         :: Text
    }


instance FromJSON Endereco where
    parseJSON = withObject "Endereco" $ \obj ->
        Endereco
            <$> obj .: "cep"
            <*> obj .: "logradouro"
            <*> obj .: "bairro"
            <*> obj .: "localidade"
            <*> obj .: "uf"


instance ToJSON Endereco where
    toJSON e = object
        [ "cep"        .= enderecoCep e
        , "logradouro" .= enderecoLogradouro e
        , "bairro"     .= enderecoBairro e
        , "cidade"     .= enderecoCidade e
        , "uf"         .= enderecoUf e
        ]


limparCep :: Text -> Text
limparCep = T.filter isDigit


buscarCep :: Text -> IO (Maybe Endereco)
buscarCep cepDigitado
    | T.length cep /= 8 = return Nothing
    | otherwise = do
        let url = "https://viacep.com.br/ws/" ++ T.unpack cep ++ "/json/"
        requisicao <- parseRequest url
      
        resultado <- try (httpLBS requisicao)
        case resultado of
            Left erro -> do
                putStrLn ("Erro ao acessar o ViaCEP: " ++ show (erro :: HttpException))
                return Nothing
            Right resposta ->
                return (decode (getResponseBody resposta :: BL.ByteString))
  where
    cep = limparCep cepDigitado
