Calculation: Dynamic POC = close of the most recent higher-timeframe bar whose volume is maximal among the lookback bars; use the higher-timeframe bar currently forming in real time and the latest completed bar historically
Calculation: HVZ high = highest high across the same higher-timeframe lookback bars
Calculation: HVZ low = lowest low across the same higher-timeframe lookback bars
Long: close > Dynamic POC AND (close is within the HVZ range OR close is within a configurable distance of Dynamic POC) AND close > open
Short: close < Dynamic POC AND (close is within the HVZ range OR close is within a configurable distance of Dynamic POC) AND close < open
Exit: long, low <= a stop price below HVZ low
Exit: short, high >= a stop price above HVZ high