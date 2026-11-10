Calculation: Volume spike = a completed lower-timeframe bar whose volume exceeds its lower-timeframe simple moving average of volume multiplied by a threshold; consider only the first limited number of lower-timeframe bars in each higher-timeframe bar.
Calculation: Imbalance counts = divide the range of the still-forming or last completed higher-timeframe bar into equal price bins; in each bin count its volume spikes with lower-timeframe close >= open and with close < open, assigning each spike by its close; include the bin's lower boundary and exclude its upper boundary.
Long: Still-forming or last completed higher-timeframe close >= its open.
Short: Still-forming or last completed higher-timeframe close < its open.
Long: A volume spike has lower-timeframe close >= open.
Short: A volume spike has lower-timeframe close < open.
Long: A higher-timeframe bar's high > low AND a price bin's count of volume spikes with lower-timeframe close >= open >= the imbalance count threshold.
Short: A higher-timeframe bar's high > low AND a price bin's count of volume spikes with lower-timeframe close < open >= the imbalance count threshold AND its count of volume spikes with close >= open < the imbalance count threshold.