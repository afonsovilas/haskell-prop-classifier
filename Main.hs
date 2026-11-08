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

factor :: Parser Prop
factor =
  do
    char '!'
    f <- factor
    return (Not f)
    <|> name
    <|> constant

main :: IO ()
main = return ()
