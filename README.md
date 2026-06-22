# Checkers Game With Computer Player
A console-based implementation of the classic Checkers game written in Haskell. The project allows a human player to compete against a computer-controlled opponent that uses the minimax algorithm with alpha-beta pruning to determine its moves.


## Features

* Standard 8×8 checkers board
* Human vs Computer gameplay
* Minimax search algorithm
* Alpha-Beta pruning optimization
* Configurable AI search depth
* Mandatory capture enforcement
* Automatic king promotion
* Legal move validation
* Win detection
* Text-based board rendering
* Pure functional board representation using `Data.Map`

## Piece Representation

The board uses the following symbols:

| Symbol | Meaning               |
| ------ | --------------------- |
| `b`    | Black Man             |
| `B`    | Black King            |
| `w`    | White Man             |
| `W`    | White King            |
| `.`    | Empty playable square |
| ` `    | Unplayable square     |

Example board:

```text
    0 1 2 3 4 5 6 7
   ----------------
0 |   b   b   b   b
1 | b   b   b   b
2 |   b   b   b   b
3 | .   .   .   .
4 |   .   .   .   .
5 | w   w   w   w
6 |   w   w   w   w
7 | w   w   w   w
```


## Rules

The implementation follows the standard rules of checkers:

* Pieces move diagonally.
* Men move forward only.
* Kings move diagonally in all directions.
* Capturing is mandatory.
* Captured pieces are removed from the board.
* A Man is promoted to a King upon reaching the opposite end of the board.
* A player wins if:

  * The opponent has no remaining pieces.
  * The opponent has no legal moves available.


## AI Opponent

The computer player uses:

### Minimax Search

The AI explores future game states and assumes that both players make optimal decisions.

### Alpha-Beta Pruning

Alpha-Beta pruning reduces the number of positions evaluated by eliminating branches that cannot influence the final decision.

### Evaluation Function

Board positions are scored using material values:

| Piece      | Value |
| ---------- | ----- |
| Black Man  | +1    |
| Black King | +3    |
| White Man  | -1    |
| White King | -3    |

Higher scores favor Black, while lower scores favor White.

## How To Run

Compile the project using GHC:

```bash
ghc -O2 Main.hs -o checkers
```

This produces an executable named:

```text
checkers
```

Run with the default AI depth:

```bash
./checkers
```

or

```bash
runghc Main.hs
```

Specify a custom search depth:

```bash
./checkers 6
```

or

```bash
runghc Main.hs 6
```

where:

```text
6 = search depth
```

Higher depths generally result in stronger play but longer thinking times.

## How To Play

The human player controls the Black pieces.

Moves are entered in the format:

```text
fromRow fromColumn toRow toColumn
```

Example:

```text
2 1 3 0
```

which means:

```text
Move piece from (2,1) to (3,0)
```

If a capture is available, only capturing moves are accepted.

---

## Project Structure

```text
Main.hs
│
├── Board Representation
├── Move Generation
├── Capture Detection
├── King Promotion
├── Game Logic
├── Board Evaluation
├── Minimax Search
├── Alpha-Beta Pruning
├── User Input Handling
└── Console Rendering
```

## Purpose Of Project

Created as a Haskell project for learning functional programming, game development, and adversarial search algorithms.