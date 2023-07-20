{-# LANGUAGE GADTs #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}

module Okapi.Parser.Headers.Operation where

import Data.ByteString qualified as BS
import Data.ByteString.Lazy qualified as LBS
import Data.ByteString.Builder qualified as Builder
import Data.List qualified as List
import Data.Text qualified as Text
import Data.Text.Encoding qualified as Text
import Network.HTTP.Types qualified as HTTP
import Network.Wai qualified as Wai
import Network.Wai.Internal qualified as Wai
import Web.HttpApiData qualified as Web
import Web.Cookie qualified as Web

data Error
  = ParseFail
  | ParamNotFound
  | CookieHeaderNotFound
  | CookieNotFound
  | HeaderValueParseFail
  | CookieValueParseFail
  deriving (Eq, Show)

data Parser a where
  Param :: Web.FromHttpApiData a => HTTP.HeaderName -> Parser a
  Cookie :: Web.FromHttpApiData a => BS.ByteString -> Parser a

eval ::
  Parser a ->
  Wai.Request ->
  (Either Error a, Wai.Request)
eval (Param name) state = case lookup name state.requestHeaders of
  Nothing -> (Left ParamNotFound, state)
  Just vBS -> case Web.parseHeaderMaybe vBS of
    Nothing -> (Left HeaderValueParseFail, state)
    Just v -> (Right v, state {Wai.requestHeaders = List.delete (name, vBS) state.requestHeaders})
eval (Cookie name) state = case lookup "Cookie" state.requestHeaders of
  Nothing -> (Left CookieHeaderNotFound, state) -- TODO: Cookie not found
  Just cookiesBS -> case lookup name $ Web.parseCookies cookiesBS of
    Nothing -> (Left CookieNotFound, state) -- TODO: Cookie parameter with given name not found
    Just valueBS -> case Web.parseHeaderMaybe valueBS of
      Nothing -> (Left CookieValueParseFail, state)
      Just value ->
        ( Right value,
          let headersWithoutCookie = List.delete ("Cookie", cookiesBS) state.requestHeaders
              newCookie = LBS.toStrict (Builder.toLazyByteString $ Web.renderCookies $ List.delete (name, valueBS) $ Web.parseCookies cookiesBS)
           in state { Wai.requestHeaders = map (\header@(headerName, _) -> if headerName == "Cookie" then ("Cookie", newCookie) else header) state.requestHeaders }
          -- TODO: Order of the cookie in the headers isn't preserved, but maybe this is fine??
        )
