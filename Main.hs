module Main where

import Data.Char
import Parsing

data Prop
  = Const Bool -- constants ( True / False )
  | Var Char -- variables
  | And Prop Prop -- conjunction
  | Or Prop Prop -- disjuntion
  | Not Prop -- negation
  deriving (Show, Eq)

name :: Parser Prop
name = do
  xs <- (satisfy isLower)
  return (Var xs)

constant :: Parser Prop
constant =
  do
    char 'T'
    return (Const True)
    <|> do
      char 'F'
      return (Const False)

term :: Parser Prop
term = do
  f <- factor
  termCont f

termCont :: Prop -> Parser Prop
termCont acc =
  do
    char '&'
    f <- factor
    termCont (And acc f)
    <|> return acc

prop :: Parser Prop
prop = do
  f <- term
  propCont f

propCont :: Prop -> Parser Prop
propCont acc =
  do
    char '|'
    f <- term
    propCont (Or acc f)
    <|> return acc

factor :: Parser Prop
factor =
  do
    char '!'
    f <- factor
    return (Not f)
    <|> name
    <|> constant
    <|> do
      char '('
      p <- prop
      char ')'
      return p

main :: IO ()
main = return ()
