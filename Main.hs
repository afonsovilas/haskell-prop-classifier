module Main where

import Data.Char
import Data.List
import Parsing

data Prop
  = Const Bool -- constants ( True / False )
  | Var Char -- variables
  | And Prop Prop -- conjunction
  | Or Prop Prop -- disjuntion
  | Not Prop -- negation
  deriving (Show, Eq)

type Subst = [(Char, Bool)]

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

vars :: Prop -> [Char]
vars (Const x) = []
vars (Var x) = [x]
vars (Not x) = vars x
vars (And x y) = nub ((vars x) ++ (vars y))
vars (Or x y) = nub ((vars x) ++ (vars y))

booleans :: Int -> [[Bool]]
booleans 0 = [[]]
booleans n = [b : s | b <- [False, True], s <- booleans (n - 1)]

substs :: Prop -> [Subst]
substs p = map (\x -> zip vs x) (booleans (length vs))
  where
    vs = vars p

eval :: Subst -> Prop -> Bool
eval _ (Const c) = c
eval sbt (Var n) = case lookup n sbt of
  Just value -> value
  Nothing -> error ("variable not found: " ++ [n])
eval sbt (Not p) = not (eval sbt p)
eval sbt (And p1 p2) = (eval sbt p1) && (eval sbt p2)
eval sbt (Or p1 p2) = (eval sbt p1) || (eval sbt p2)

classify :: Prop -> String
classify p
  | and results = "TAUTOLOGY"
  | not (or results) = "CONTRADICTION"
  | otherwise = "CONTINGENT"
  where
    results = map (\s -> eval s p) (substs p)

main :: IO ()
main = return ()
