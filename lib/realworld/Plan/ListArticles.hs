{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LinearTypes #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

module Plan.ListArticles where

import Data (ArticlesQuery (..), Limit (..), Offset (..), Tag, User (..), Username)
import qualified Data.Aeson as Aeson
import qualified Data.OpenApi as OAPI
import Data.Text (Text)
import GHC.Generics (Generic)
import Okapi.Endpoint
import Okapi.Script.AddHeader (Response)
import qualified Okapi.Script.AddHeader as AddHeader
import qualified Okapi.Script.Body as Body
import qualified Okapi.Script.Headers as Headers
import qualified Okapi.Script.Path as Path
import qualified Okapi.Script.Query as Query
import qualified Okapi.Script.Responder as Responder
import qualified Web.HttpApiData as Web

plan =
  Plan
    { transformer = id,
      endpoint =
        Endpoint
          { method = GET,
            path = Path.static "articles",
            query = do
              tag <- Query.optional $ Query.param @Tag "tag"
              author <- Query.optional $ Query.param @Username "author"
              favorited <- Query.optional $ Query.param @Username "favorited"
              limit <- Query.option (Limit 20) $ Query.param @Limit "limit"
              offset <- Query.option (Offset 0) $ Query.param @Offset "offset"
              pure ArticlesQuery {..},
            body = pure (),
            headers = pure (),
            responder = Responder.json @User status200 $ pure ()
          },
      handler = \_ _ _ userRegistration responder -> do
        print userRegistration
        return $ responder (\() response -> response) User
    }
