import qualified Data.Map as Map
import Data.Map (Map)
import Data.List (minimumBy)
import Data.Ord (comparing)

import System.Environment (getArgs)
import Text.Read (readMaybe)


-- Data types

type Position = (Int, Int)

data Player =  White | Black
    deriving (Eq, Show)

data PieceType = Man | King
    deriving (Eq, Show)

data Piece = Piece Player PieceType
    deriving (Eq, Show)

type Board = Map Position Piece

data Move = Move Position Position (Maybe Position)
    deriving (Eq, Show)

-- Game parameters

boardSize :: Int
boardSize = 8

human :: Player
human = Black

computer :: Player
computer = White

fixedDepth :: Int
fixedDepth = 5

winForBlack :: Int
winForBlack = 1000

winForWhite :: Int
winForWhite = -1000

alpha :: Int
alpha = -10000

beta :: Int
beta = 10000

-- Initialize the board with pieces in their starting positions

initialBoard :: Board
initialBoard =
    Map.fromList $ blackPieces ++ whitePieces
  where
    blackPieces = [((r, c), Piece Black Man) | r <- [0..2], c <- [0..boardSize - 1], blackSquare (r, c)]
    whitePieces = [((r, c), Piece White Man) | r <- [5..7], c <- [0..boardSize - 1], blackSquare (r, c)]

blackSquare :: Position -> Bool
blackSquare (r, c) = odd (r + c)

-- Check if a position is within the bounds of the board

insideBoard :: Position -> Bool
insideBoard (r, c) = 
    r >= 0 && r < boardSize && c >= 0 && c < boardSize


-- Get the opponent of a player

opponent :: Player -> Player
opponent White = Black
opponent Black = White


-- Get the possible move directions for a piece

directions :: Piece -> [(Int, Int)]
directions (Piece White Man) = [(-1, -1), (-1, 1)]
directions (Piece Black Man) = [(1, -1), (1, 1)]
directions (Piece _ King) = [(-1, -1), (-1, 1), (1, -1), (1, 1)]

getPiece :: Board -> Position -> Maybe Piece
getPiece board pos = 
    Map.lookup pos board

isEmpty :: Board -> Position -> Bool
isEmpty board pos =
    insideBoard pos && not (Map.member pos board)

belongsTo :: Player -> Piece -> Bool
belongsTo player (Piece owner _) = 
    owner == player


-- Generate all possible moves for a piece at a given position

normalMoves :: Board -> Position -> Piece -> [Move]
normalMoves board (r, c) piece =
    [ Move (r, c) (r + dr, c + dc) Nothing
    | (dr, dc) <- directions piece
    , let newPos = (r + dr, c + dc)
    , isEmpty board newPos
    ]


-- Generate all possible capture moves for a piece at a given position

captureMoves :: Board -> Position -> Piece -> [Move]
captureMoves board (r, c) piece =
    [ Move (r, c) (r + 2 * dr, c + 2 * dc) (Just (r + dr, c + dc))
    | (dr, dc) <- directions piece
    , let midPos = (r + dr, c + dc)
    , let newPos = (r + 2 * dr, c + 2 * dc)
    , insideBoard newPos
    , isEmpty board newPos
    , case getPiece board midPos of
        Just midPiece -> belongsTo (opponent (pieceOwner piece)) midPiece
        Nothing -> False
    ]

pieceOwner :: Piece -> Player
pieceOwner (Piece owner _) = owner

-- Generate all possible capture moves for a player

allCaptureMoves :: Board -> Player -> [Move]
allCaptureMoves board player =
    concat [captureMoves board position piece | (position, piece) <- Map.toList board, belongsTo player piece]

-- Generate all possible normal moves for a player

allNormalMoves :: Board -> Player -> [Move]
allNormalMoves board player =
    concat [normalMoves board position piece | (position, piece) <- Map.toList board, belongsTo player piece]

-- Get all allowed moves for a player, prioritizing captures over normal moves

allowedMoves :: Board -> Player -> [Move]
allowedMoves board player =
    let captures = allCaptureMoves board player
    in if not (null captures)
       then captures
       else allNormalMoves board player

-- Apply a move to the board, returning the new board state

moveOnBoard :: Board -> Move -> Board
moveOnBoard board (Move from to captured) =
    case Map.lookup from board of
        Nothing -> board

        Just piece ->
            let promoted = promoteToKing to piece
                board1 = Map.delete from board
                board2 =
                    case captured of
                        Nothing -> board1
                        Just capturedPosition -> Map.delete capturedPosition board1
            in Map.insert to promoted board2

promoteToKing :: Position -> Piece -> Piece
promoteToKing (r, _) (Piece White Man)
    | r == 0 = Piece White King

promoteToKing (r, _) (Piece Black Man)
    | r == boardSize - 1 = Piece Black King

promoteToKing _ piece = piece

-- Check if a player has any pieces left on the board

hasPieces :: Board -> Player -> Bool
hasPieces board player =
    any (belongsTo player) (Map.elems board)


winner :: Board -> Maybe Player
winner board
    | not (hasPieces board Black) = Just White
    | not (hasPieces board White) = Just Black
    | null (allowedMoves board Black) = Just White
    | null (allowedMoves board White) = Just Black
    | otherwise = Nothing


-- Evaluate the board state for the computer player (White) and the human player (Black)

evaluate :: Board -> Int
evaluate board = sum [pieceValue piece | piece <- Map.elems board]
  where
    pieceValue (Piece Black Man) = -1
    pieceValue (Piece Black King) = -3
    pieceValue (Piece White Man) = 1
    pieceValue (Piece White King) = 3


-- Alpha-beta pruning algorithm to find the best move for the computer player (White)

alphaBeta :: Int -> Int -> Int -> Player -> Board -> Int
alphaBeta depth alpha beta player board =
    case winner board of
        Just Black -> winForBlack
        Just White -> winForWhite
        Nothing
            | depth == 0 -> evaluate board
            | player == Black -> maximize alpha beta (allowedMoves board player)
            | player == White -> minimize alpha beta (allowedMoves board player)

        where
            maximize a b [] = a
            maximize a b (move : moves) =
                let score = alphaBeta (depth - 1) a b (opponent player) (moveOnBoard board move)
                    a_max = max a score
                in if a_max >= b
                   then a_max
                   else maximize a_max b moves

            
            minimize a b [] = b
            minimize a b (move : moves) =
                let score = alphaBeta (depth - 1) a b (opponent player) (moveOnBoard board move)
                    b_min = min b score
                in if b_min <= a
                   then b_min
                   else minimize a b_min moves