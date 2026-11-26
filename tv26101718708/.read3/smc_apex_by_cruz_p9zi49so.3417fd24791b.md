Calculation: Latest confirmed swing high = most recent non-na PivotHigh(high, swing lookback, swing lookback)
Calculation: Latest confirmed swing low = most recent non-na PivotLow(low, swing lookback, swing lookback)
Calculation: Bullish structure break = close crosses above latest confirmed swing high
Calculation: Bearish structure break = close crosses below latest confirmed swing low
Calculation: Bullish FVG = low > high[2] AND 100 * (low - high[2]) / high[2] >= minimum gap percentage
Calculation: Bearish FVG = low[2] > high AND 100 * (low[2] - high) / high >= minimum gap percentage
Calculation: Bullish entry candidate = after a bullish structure break with close above or below EMA(close, trend lookback), retain the most recent bullish FVG formed since that break; candidate when low <= its upper boundary AND close >= its lower boundary AND close > EMA(close, trend lookback), then clear the candidate
Calculation: Bearish entry candidate = after a bearish structure break with close above or below EMA(close, trend lookback), retain the most recent bearish FVG formed since that break; candidate when high >= its lower boundary AND close <= its upper boundary AND close < EMA(close, trend lookback), then clear the candidate
Long: bullish structure break AND close > EMA(close, trend lookback) AND bars since the last structure label >= label cooldown
Long: bullish structure break AND close < EMA(close, trend lookback) AND bars since the last structure label >= label cooldown
Long: bullish FVG AND close > EMA(close, trend lookback)
Long: bullish entry candidate AND close > Highest(high, breakout lookback)[1] AND bars since the last breakout signal >= signal cooldown AND session signal count < session maximum
Short: bearish structure break AND close < EMA(close, trend lookback) AND bars since the last structure label >= label cooldown
Short: bearish structure break AND close > EMA(close, trend lookback) AND bars since the last structure label >= label cooldown
Short: bearish FVG AND close < EMA(close, trend lookback)
Short: bearish entry candidate AND close < Lowest(low, breakout lookback)[1] AND bars since the last breakout signal >= signal cooldown AND session signal count < session maximum