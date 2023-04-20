# Okapi

A micro web framework based on monadic parsing. Official documentation [here](https://www.okapi.wiki/).

## Introduction

**Okapi** is a micro web framework for Haskell.
In contrast to other web frameworks in the Haskell ecosystem, Okapi is primarily concerned with being easy to understand and use, instead of extreme type safety.

Here's an example of a simple web server:

```haskell
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

import Data.Text
import Okapi

main :: IO ()
main = run greet

greet = do
  methodGET
  pathParam @Text `is` "greet"
  name <- pathParam
  pathEnd
  return $ setPlaintext ("Hello " <> name <> "! I'm Okapi.") $ ok
```

Running this code will start a server on [localhost:3000](http://localhost:3000.org).
If you go to [http://localhost:3000/greeting/Bob]() the server will respond with

```Hello Bob! I'm Okapi.```

in plain text format.

Okapi provides [monadic parsers](https://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf) for extracting data from HTTP requests.
Since they are monads, parsers can be used with all `Applicative`, `Alternative`, and `Monad` typeclass methods, plus other Haskell idioms like [parser combinators](https://hackage.haskell.org/package/parser-combinators).
Because of this, parsers are very modular and can be easily composed with one another to fit your specific needs.

With Okapi, and the rest of the Haskell ecosystem, you can create anything from simple website servers to complex APIs for web apps.
All you need to get started is basic knowledge about the structure of HTTP requests and an idea of how monadic parsing works.
