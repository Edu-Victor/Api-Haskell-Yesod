module Handler.Avaliacao where

import Yesod
import Network.HTTP.Types (status201)
import Foundation
import Models
import Util

getAvaliacoesR :: Handler Value
getAvaliacoesR = do
    avaliacoes <- runDB (selectList [] [Asc AvaliacaoId])
    returnJson avaliacoes


postAvaliacoesR :: Handler Value
postAvaliacoesR = do
    avaliacao <- requireCheckJsonBody :: Handler Avaliacao
    validarAvaliacao avaliacao
    avaliacaoId <- runDB (insert avaliacao)
    sendStatusJSON status201 (Entity avaliacaoId avaliacao)


getAvaliacaoR :: AvaliacaoId -> Handler Value
getAvaliacaoR avaliacaoId = do
    avaliacao <- runDB (get404 avaliacaoId)
    returnJson (Entity avaliacaoId avaliacao)


putAvaliacaoR :: AvaliacaoId -> Handler Value
putAvaliacaoR avaliacaoId = do
    _ <- runDB (get404 avaliacaoId)
    avaliacao <- requireCheckJsonBody :: Handler Avaliacao
    validarAvaliacao avaliacao
    runDB (replace avaliacaoId avaliacao)
    returnJson (Entity avaliacaoId avaliacao)


deleteAvaliacaoR :: AvaliacaoId -> Handler Value
deleteAvaliacaoR avaliacaoId = do
    _ <- runDB (get404 avaliacaoId)
    runDB (delete avaliacaoId)
    returnJson (mensagem "Avaliacao excluida com sucesso")


validarAvaliacao :: Avaliacao -> Handler ()
validarAvaliacao avaliacao = do
    let nota = avaliacaoNota avaliacao
    validar (nota >= 1 && nota <= 5) "A nota deve ser de 1 a 5"
    _ <- buscarOuFalhar (avaliacaoLivroId avaliacao)  "Livro informado nao existe"
    _ <- buscarOuFalhar (avaliacaoLeitorId avaliacao) "Leitor informado nao existe"
    return ()
