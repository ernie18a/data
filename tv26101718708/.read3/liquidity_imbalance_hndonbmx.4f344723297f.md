Calculation: bar range = high - low
Calculation: average bar range = SMA(bar range, average lookback)
Calculation: average volume = SMA(volume, average lookback)
Calculation: upper value area = VWAP(hlc3) + deviation multiplier * standard deviation(close, deviation lookback)
Short: On chart bars, using T1 values mapped with lookahead off (the T1 bar still forming in real time and the last completed T1 bar historically), T1 high > T1 high[1] AND T1 high[1] > T1 high[2] AND T1 close < T1 high[1], where [1] and [2] index chart bars
Short: high > highest(high, sweep lookback)[1] AND close < highest(high, sweep lookback)[1]
Long: low < lowest(low, sweep lookback)[1] AND close > lowest(low, sweep lookback)[1]
Long: close > open AND bar range > average bar range * range multiplier AND volume > average volume * volume multiplier
Short: close < open AND bar range > average bar range * range multiplier AND volume > average volume * volume multiplier
Short: during session S1 AND T1 high > T1 high[1] AND T1 high[1] > T1 high[2] AND T1 close < T1 high[1] AND high[1] > upper value area[1] AND high < upper value area AND volume < average volume