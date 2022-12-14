module ParserComb where

import Control.Applicative
import Control.Monad
import Data.Char

newtype ParserX a = P (String -> [(a, String)])

-- resultX :: a -> ParserX a
-- resultX v = \inp -> [(v, inp)]

-- zeroX :: ParserX a
-- zeroX = \inp -> []

itemX :: ParserX Char
itemX = P (\inp -> case inp of
                  [] -> []
                  (x:xs) -> [(x,xs)])



parse :: ParserX a -> String -> [(a, String)]
parse (P p) s = p s

instance Functor ParserX where
    fmap f pa = P $ \input -> case parse pa input of
                               []        -> []
                               [(v,out)] -> [(f v, out)]


instance Applicative ParserX where
    pure x = P $ \v -> [(x, v)]
    fa <*> ga = P $ \input -> case parse fa input of
                               [] -> []
                               [(f, out)] -> parse (fmap f ga) out

instance Monad ParserX where
    return x = P $ \input -> [(x, input)]
    p >>= f = P $ \input -> case parse p input of
                             [] -> []
                             [(x, out)] -> parse (f x) out

instance Alternative ParserX where
    empty = P $ \input -> []
    p <|> q = P $ \input -> case parse p input of
                              []         -> parse q input
                              [(x, out)] -> [(x, out)] 

sat :: (Char -> Bool) -> ParserX Char 
sat p = do x <- itemX
           if p x then return x else empty


