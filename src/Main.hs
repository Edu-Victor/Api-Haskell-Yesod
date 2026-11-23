{-# OPTIONS_GHC -Wno-orphans #-}
module Main where

import Yesod
import Control.Monad.Logger (runStdoutLoggingT)
import Data.Maybe (fromMaybe)
import qualified Data.ByteString.Char8 as BS8
import Database.Persist.Postgresql
import System.Environment (lookupEnv)
import System.IO (hSetEncoding, stdout, utf8)

import Foundation
import Models
import Handler.Home
import Handler.Autor
import Handler.Editora
import Handler.Categoria
import Handler.Livro
import Handler.Leitor
import Handler.Emprestimo
import Handler.Avaliacao
import Handler.Cep
import Handler.Reset


mkYesodDispatch "App" resourcesApp


variavel :: String -> String -> IO String
variavel nome padrao = do
    valor <- lookupEnv nome
    return (fromMaybe padrao valor)



obrigatoria :: String -> IO String
obrigatoria nome = do
    valor <- lookupEnv nome
    case valor of
        Just v  -> return v
        Nothing -> error ("Variavel de ambiente nao definida: " ++ nome)

montarConexao :: IO ConnectionString
montarConexao = do
    host    <- obrigatoria "DB_HOST"
    porta   <- obrigatoria "DB_PORT"
    usuario <- obrigatoria "DB_USER"
    senha   <- obrigatoria "DB_PASSWORD"
    banco   <- obrigatoria "DB_NAME"
    ssl     <- obrigatoria "DB_SSLMODE"
    let texto = unwords
            [ "host="     ++ entreAspas host
            , "port="     ++ entreAspas porta
            , "user="     ++ entreAspas usuario
            , "password=" ++ entreAspas senha
            , "dbname="   ++ entreAspas banco
            , "sslmode="  ++ entreAspas ssl
            ]
    return (BS8.pack texto)


entreAspas :: String -> String
entreAspas valor = "'" ++ concatMap escapar valor ++ "'"
  where
    escapar '\'' = "\\'"
    escapar '\\' = "\\\\"
    escapar c    = [c]

main :: IO ()
main = do
    hSetEncoding stdout utf8
    conexao <- montarConexao
    
    porta <- read <$> variavel "PORT" "3000"
  
    runStdoutLoggingT $ withPostgresqlPool conexao 10 $ \pool -> liftIO $ do
        
        runSqlPool (runMigration migrateAll) pool
        putStrLn ("Servidor rodando na porta " ++ show porta)
        warp porta (App pool)
