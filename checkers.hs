import qualified Data.Map as Map
import Data.Map (Map)
import Data.List (minimumBy)
import Data.Ord (comparing)

import System.Environment (getArgs)
import Text.Read (readMaybe)

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