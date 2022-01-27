module Wordlist where

import GHC.Exts (sortWith)
import Data.List (sort, group)
import qualified Data.Map.Strict as M
import qualified Data.Set as S

type Letters  = String                 -- ^Set of letters the word consists
type Anagrams = S.Set String           -- ^Set of words which are anagrams
type FreqMap  = M.Map Char Int         -- ^Character frequency map
type WordMap  = M.Map Letters Anagrams -- ^Map of all words (grouped by anagrams)

-- |Group words into Map of anagrams
toAnagramMap :: Foldable t => t String -> WordMap
toAnagramMap words = project toLetters words

-- |Convert word to sorted distinct letter sequence
toLetters :: String -> Letters
toLetters = map head . group . sort

-- |Has specific length
hasLength :: Int -> String -> Bool
hasLength n xs = length xs == n

-- |Letter frequency of words.
frequency :: String -> FreqMap
frequency words = M.fromListWith (+) $ map toFreq words
  where toFreq a = (a,1)

-- |Letter frequencies in descending order.
toFreqList :: FreqMap -> [(Char, Int)]
toFreqList = sortWith (negate . snd) . M.toList

-- |Calculates frequency point for the word. Just adds frequencies of
-- each letter.
points :: FreqMap -> String -> Int
points m xs = sum $ map (m M.!) xs

-- |Insert the values into a map, using projection function as a
-- key. The function doesn't need to be injection. The returned map
-- key is the value of the projection function and the value is a set
-- of values having that projection.
project :: (Foldable t, Ord k, Ord a) => (a -> k) -> t a -> M.Map k (S.Set a)
project f xs = foldl inserter M.empty xs
  where
    -- Function which inserts values to the map
    inserter m x = M.alter (alternator x) (f x) m
    -- Adds item to the list if any, otherwise create singleton list
    alternator x = Just . maybe (S.singleton x) (S.insert x)
