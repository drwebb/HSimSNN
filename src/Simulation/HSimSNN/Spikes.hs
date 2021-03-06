{-# LANGUAGE DeriveFunctor #-}
-- | Module for handling spikes
--
module Simulation.HSimSNN.Spikes where

import qualified Data.Vector as V
import Data.Monoid

-- | SpikeTrain data type consists of a vector of tuples of the form (index, time)
-- You can initialize a SpikeTrain as follows
--
-- @
--      > import qualified Data.Vector.Unboxed as V
--      > let indx = V.fromList [0..20]
--      > let spktm = V.fromList [5.0,5.1..7]
--      > let spktrain = SpikeTrain $ V.zip indx spktm
-- @
--
-- Note 1 - the index is Int and not Double
-- Note 2 - TODO: SpikeTrain (V.fromList []) != EmptySpikeTrain although conceptually it is.
data SpikeTrain a = SpikeTrain {unSpikeTrain :: (V.Vector a)} | EmptySpikeTrain
                     deriving (Show, Eq, Functor)

instance (Monoid a) => Monoid (SpikeTrain a) where
  mempty = EmptySpikeTrain
  (SpikeTrain a) `mappend` (SpikeTrain b) = SpikeTrain (a `mappend` b)  

-- | Concatenate two 'SpikeTrain's 
-- this is monoid
concST :: SpikeTrain a -> SpikeTrain a -> SpikeTrain a
concST EmptySpikeTrain st = st
concST st EmptySpikeTrain = st
concST (SpikeTrain v1) (SpikeTrain v2) = SpikeTrain (v1 V.++ v2)


-- | Represents next time of spike of a neuron
data NextSpikeTime = At Double | Never
instance Eq NextSpikeTime where
    (==) Never Never = True
    (==) Never (At t) = False
    (==) (At t) Never = False
    (==) (At t1) (At t2) = (t1 == t2)
instance Ord NextSpikeTime where
    (<=) Never Never = True
    (<=) Never (At t) = False
    (<=) (At t) Never = True
    (<=) (At t1) (At t2) = (t1 <= t2)

-- | Extract time from NextSpikeTime
getTime::NextSpikeTime -> Double
getTime (At t) = t
getTime Never = error "There is no spike"
