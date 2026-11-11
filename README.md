# Logical Calculator in Haskell

First individual project for **Functional and Logic Programming (PFL)**, L.EIC, 2026/27.

The program reads logical propositions from standard input, one per line, and classifies each one as:

| Classification | Meaning |
|---|---|
| `TAUTOLOGY` | true for every assignment of truth values to the variables |
| `CONTRADICTION` | false for every assignment |
| `CONTINGENT` | true or false depending on the assignment |

## Proposition syntax

| Symbol | Meaning |
|---|---|
| `a` … `z` | variable (a single lowercase letter) |
| `T`, `F` | true / false constants |
| `!` | negation |
| `&` | conjunction |
| `\|` | disjunction |
| `(` `)` | grouping |

Grammar:

```
prop     ::= term propCont
propCont ::= '|' term propCont | ε
term     ::= factor termCont
termCont ::= '&' factor termCont | ε
factor   ::= '!' factor | name | constant | '(' prop ')'
constant ::= 'T' | 'F'
```

- Negation has the highest precedence, then conjunction, then disjunction. So `x|y&z` is read as `x|(y&z)`.
- `&` and `|` are left-associative: `a&b&c` is read as `(a&b)&c`.
- Spaces are **not** allowed. A line that does not match the grammar prints `parse error; try again`.

## Building and running

You need [GHC](https://www.haskell.org/ghcup/) installed.

```bash
ghc Main.hs
```

```bash
./Main < input.txt
```

You can also type propositions by hand: run `./Main`, enter one per line and finish with `Ctrl+D`.

## Example

Input:

```
T
a&F
a
a|!a
!p&!!p
p&T|p
p|!p&q
p&!p&p
!(p&q)|p
```

Output:

```
TAUTOLOGY
CONTRADICTION
CONTINGENT
TAUTOLOGY
CONTRADICTION
CONTINGENT
CONTINGENT
CONTRADICTION
TAUTOLOGY
```

## Project structure

| File | Contents |
|---|---|
| `Main.hs` | the program: `Prop` type, parser, evaluation, classification and `main` |
| `Parsing.hs` | parsing library from Lecture 11, used unchanged |
| `Calculator.hs` | arithmetic calculator from Lecture 11, used as a model |

## How it works

1. **Parsing.** Each line is turned into a tree of type:

   ```haskell
   data Prop = Const Bool | Var Char | And Prop Prop | Or Prop Prop | Not Prop
   ```

   The parser follows the grammar above, with one function per rule (`prop`, `propCont`, `term`, `termCont`, `factor`, `name`, `constant`). `propCont` and `termCont` take the tree built so far as an accumulator, which gives left associativity. A line is only accepted if the parser consumes all of it.

2. **Truth table.**
   - `vars` collects the variables of the proposition, without duplicates.
   - `booleans n` generates all 2ⁿ combinations of truth values.
   - `substs` combines the two to produce every possible assignment.
   - `eval` computes the value of the proposition under one assignment.

3. **Classification.** `classify` evaluates the proposition under every assignment: if every result is true, it is a `TAUTOLOGY`; if none is, it is a `CONTRADICTION`; otherwise it is `CONTINGENT`.

## Limitations

- The number of assignments grows exponentially with the number of distinct variables. Up to about 20 variables the answer is practically instant; with 26 it takes several seconds.
- Lines with Windows line endings (`\r\n`) are rejected, because `\r` is not part of the grammar.

## Author

Afonso Vilas
