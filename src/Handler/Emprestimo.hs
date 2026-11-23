module Handler.Emprestimo where

import Yesod
import Control.Monad (when)
import Data.Aeson (withObject)
import Data.Maybe (isNothing)
import Data.Time (Day, getCurrentTime, utctDay)
import Network.HTTP.Types (status201)
import Foundation
import Models
import Util


data EmprestimoEntrada = EmprestimoEntrada
    { entradaLivroId  :: LivroId
    , entradaLeitorId :: LeitorId
    }

instance FromJSON EmprestimoEntrada where
    parseJSON = withObject "EmprestimoEntrada" $ \obj ->
        EmprestimoEntrada
            <$> obj .: "livroId"
            <*> obj .: "leitorId"


hoje :: Handler Day
hoje = liftIO (utctDay <$> getCurrentTime)


getEmprestimosR :: Handler Value
getEmprestimosR = do
    emprestimos <- runDB (selectList [] [Desc EmprestimoDataEmprestimo])
    returnJson emprestimos


postEmprestimosR :: Handler Value
postEmprestimosR = do
    entrada <- requireCheckJsonBody :: Handler EmprestimoEntrada
    let livroId  = entradaLivroId entrada
        leitorId = entradaLeitorId entrada
    livro <- buscarOuFalhar livroId  "Livro informado nao existe"
    _     <- buscarOuFalhar leitorId "Leitor informado nao existe"
    validar (livroQuantidade livro > 0) "Nao ha exemplares disponiveis deste livro"
    dataAtual <- hoje
    let emprestimo = Emprestimo
            { emprestimoLivroId        = livroId
            , emprestimoLeitorId       = leitorId
            , emprestimoDataEmprestimo = dataAtual
            , emprestimoDataDevolucao  = Nothing
            }
  
    emprestimoId <- runDB $ do
        novoId <- insert emprestimo
        update livroId [LivroQuantidade -=. 1]
        return novoId
    sendStatusJSON status201 (Entity emprestimoId emprestimo)


getEmprestimoR :: EmprestimoId -> Handler Value
getEmprestimoR emprestimoId = do
    emprestimo <- runDB (get404 emprestimoId)
    returnJson (Entity emprestimoId emprestimo)


putDevolucaoR :: EmprestimoId -> Handler Value
putDevolucaoR emprestimoId = do
    emprestimo <- runDB (get404 emprestimoId)
    validar (isNothing (emprestimoDataDevolucao emprestimo)) "Este emprestimo ja foi devolvido"
    dataAtual <- hoje
    runDB $ do
        update emprestimoId [EmprestimoDataDevolucao =. Just dataAtual]
        update (emprestimoLivroId emprestimo) [LivroQuantidade +=. 1]
    let atualizado = emprestimo { emprestimoDataDevolucao = Just dataAtual }
    returnJson (Entity emprestimoId atualizado)


deleteEmprestimoR :: EmprestimoId -> Handler Value
deleteEmprestimoR emprestimoId = do
    emprestimo <- runDB (get404 emprestimoId)
    runDB $ do
        delete emprestimoId
        when (isNothing (emprestimoDataDevolucao emprestimo)) $
            update (emprestimoLivroId emprestimo) [LivroQuantidade +=. 1]
    returnJson (mensagem "Emprestimo excluido com sucesso")
