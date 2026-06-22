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