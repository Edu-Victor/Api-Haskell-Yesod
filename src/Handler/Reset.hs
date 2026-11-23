module Handler.Reset where

import Yesod
import Database.Persist.Sql (rawExecute)
import Foundation
import Util


postResetR :: Handler Value
postResetR = do
    runDB (rawExecute
        "TRUNCATE TABLE avaliacao, emprestimo, livro, leitor, autor, editora, categoria RESTART IDENTITY CASCADE"
        [])
    returnJson (mensagem "Banco resetado com sucesso")