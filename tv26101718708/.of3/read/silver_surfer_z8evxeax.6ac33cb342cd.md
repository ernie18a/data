Calculation: CISD = first tests whether close crosses above the open stored from the latest prior bearish non-inside bar or below the open stored from the latest prior bullish non-inside bar; a non-inside bar has NOT (high < high[1] AND low > low[1]); then updates the bearish or bullish stored open on a bearish or bullish non-inside bar, respectively; otherwise retains its state, initially neutral
Calculation: Bullish FVG = low > high[2]
Calculation: Bearish FVG = high < low[2]
Long: Bullish FVG
Short: Bearish FVG
Long: position is flat AND CISD on chart bars is bullish AND CISD on higher-timeframe T1 bars is bullish, sampled on chart bars (last completed T1 bar historically; T1 bar still forming in real time) AND Bullish FVG AND (BOS filter is disabled OR high > highest(high, lookback)[1])
Short: position is flat AND CISD on chart bars is bearish AND CISD on higher-timeframe T1 bars is bearish, sampled on chart bars (last completed T1 bar historically; T1 bar still forming in real time) AND Bearish FVG AND (BOS filter is disabled OR low < lowest(low, lookback)[1])
Exit: long, low <= close[1] - ATR(lookback)[1] * stop-distance multiplier OR high >= close[1] + ATR(lookback)[1] * stop-distance multiplier * risk-reward ratio
Exit: short, high >= close[1] + ATR(lookback)[1] * stop-distance multiplier OR low <= close[1] - ATR(lookback)[1] * stop-distance multiplier * risk-reward ratio