Calculation: Structure pivots(lookback) = retain the latest high and low from alternating leg reversals; a high pivot occurs when high[lookback] > highest(high, lookback), and a low pivot occurs when low[lookback] < lowest(low, lookback). Use separate internal and swing lookbacks, with the internal lookback shorter than the swing lookback.
Calculation: Structure bias = direction of the most recent structure break.
Long: close crosses above the latest unbroken internal structure high AND the internal high differs from the swing structure high AND (confluence filtering is off OR the upper wick is longer than the lower wick) AND the configured bullish internal structure output permits the break's BOS or MSS class.
Short: close crosses below the latest unbroken internal structure low AND the internal low differs from the swing structure low AND (confluence filtering is off OR the upper wick is shorter than the lower wick) AND the configured bearish internal structure output permits the break's BOS or MSS class.
Long: close crosses above the latest unbroken swing structure high AND the configured bullish swing structure output permits the break's BOS or MSS class.
Short: close crosses below the latest unbroken swing structure low AND the configured bearish swing structure output permits the break's BOS or MSS class.
Long: internal structure bias is bullish.
Short: internal structure bias is bearish.
Long: at a newly confirmed price pivot low, its low is below the preceding price pivot low AND RSI(close, RSI lookback) at the new pivot is above RSI at the preceding pivot; confirm price pivots with the pivot lookback on each side.
Short: at a newly confirmed price pivot high, its high is above the preceding price pivot high AND RSI(close, RSI lookback) at the new pivot is below RSI at the preceding pivot; confirm price pivots with the pivot lookback on each side.
Long: low < current CISD structure bottom AND ((a bearish pullback is active and its recorded break bar precedes the current bar) OR (close[1] > open[1] AND close < open)).
Short: high > current CISD structure top AND ((a bullish pullback is active and its recorded break bar precedes the current bar) OR (close[1] < open[1] AND close > open)).
Long: close > the active -CISD level.
Short: close < the active +CISD level.
Long: low - high[2] > ATR(void lookback) AND close[1] > high[2].
Short: low[2] - high > ATR(void lookback) AND close[1] < low[2].