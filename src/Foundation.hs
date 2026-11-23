
module Foundation where

import Yesod
import Data.Text (Text)
import qualified Data.Text as T
import Database.Persist.Sql (ConnectionPool, SqlBackend, runSqlPool)
import Models


data App = App
    { appPool :: ConnectionPool
    }


mkYesodData "App" [parseRoutes|
/                                     HomeR             GET

/autores                              AutoresR          GET POST
/autores/#AutorId                     AutorR            GET PUT DELETE

/editoras                             EditorasR         GET POST
/editoras/#EditoraId                  EditoraR          GET PUT DELETE

/categorias                           CategoriasR       GET POST
/categorias/#CategoriaId              CategoriaR        GET PUT DELETE

/livros                               LivrosR           GET POST
/livros/#LivroId                      LivroR            GET PUT DELETE
/livros/#LivroId/avaliacoes           LivroAvaliacoesR  GET

/leitores                             LeitoresR         GET POST
/leitores/#LeitorId                   LeitorR           GET PUT DELETE

/emprestimos                          EmprestimosR      GET POST
/emprestimos/#EmprestimoId            EmprestimoR       GET DELETE
/emprestimos/#EmprestimoId/devolucao  DevolucaoR        PUT

/avaliacoes                           AvaliacoesR       GET POST
/avaliacoes/#AvaliacaoId              AvaliacaoR        GET PUT DELETE

/cep/#Text                            CepR              GET
|]


instance Yesod App where
  
    makeSessionBackend _ = return Nothing


    errorHandler NotFound           = erroEmJson "Recurso nao encontrado"
    errorHandler (InvalidArgs msgs) = erroEmJson (T.intercalate "; " msgs)
    errorHandler (BadMethod _)      = erroEmJson "Metodo HTTP nao permitido nesta rota"
    errorHandler (InternalError m)  = erroEmJson m
    errorHandler outroErro          = defaultErrorHandler outroErro

erroEmJson :: Text -> Handler TypedContent
erroEmJson mensagem = return (toTypedContent (object ["erro" .= mensagem]))


instance YesodPersist App where
    type YesodPersistBackend App = SqlBackend
    runDB acao = do
        app <- getYesod
        runSqlPool acao (appPool app)
