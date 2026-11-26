Long: EMA(close, shorter lookback) > EMA(close, longer lookback) AND Momentum(close, separate lookback) > momentum threshold
Short: EMA(close, shorter lookback) < EMA(close, longer lookback) AND Momentum(close, separate lookback) < momentum threshold
Calculation: Bullish FVG = high[gap lookback] < low AND high[gap lookback] is positive AND (low - high[gap lookback]) / high[gap lookback] >= minimum gap fraction
Calculation: Bearish FVG = low[gap lookback] > high AND low[gap lookback] is positive AND (low[gap lookback] - high) / low[gap lookback] >= minimum gap fraction
Long: Bullish FVG on chart bars OR, for any of T1–T4, chart timeframe is shorter than T and a Bullish FVG on the still-forming T bar first becomes true on a chart bar after being false on the preceding chart bar, with T bar values sampled on chart bars using lookahead off
Short: Bearish FVG on chart bars OR, for any of T1–T4, chart timeframe is shorter than T and a Bearish FVG on the still-forming T bar first becomes true on a chart bar after being false on the preceding chart bar, with T bar values sampled on chart bars using lookahead off
Long: chart-bar high > the latest unbroken high of any enabled session
Short: chart-bar low < the latest unbroken low of any enabled session
Long: chart-bar high > the high of the last completed T4 bar, sampled on chart bars, and that level has not already been marked broken during the current T4 bar
Short: chart-bar low < the low of the last completed T4 bar, sampled on chart bars, and that level has not already been marked broken during the current T4 bar