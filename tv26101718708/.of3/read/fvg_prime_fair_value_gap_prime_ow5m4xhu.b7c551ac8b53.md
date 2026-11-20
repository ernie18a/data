Calculation: Bullish FVG = low > high[2] AND close[1] > high[2] AND low - high[2] >= ATR(ATR lookback) × gap size multiplier; zone boundaries are high[2] and low
Calculation: Bearish FVG = high < low[2] AND close[1] < low[2] AND low[2] - high >= ATR(ATR lookback) × gap size multiplier; zone boundaries are high and low[2]
Long: confirmed bar close AND Bullish FVG
Short: confirmed bar close AND Bearish FVG
Long: on a confirmed bar close, an earlier bullish FVG that has not previously been mitigated at its midpoint or signaled before is touched (low <= its upper boundary) AND close > its upper boundary AND close > open AND close > EMA(close, EMA lookback)
Short: on a confirmed bar close, an earlier bearish FVG that has not previously been mitigated at its midpoint or signaled before is touched (high >= its lower boundary) AND close < its lower boundary AND close < open AND close < EMA(close, EMA lookback)