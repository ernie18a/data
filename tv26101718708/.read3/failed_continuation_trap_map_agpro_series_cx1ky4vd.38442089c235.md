Calculation: continuation level = Highest(high[1], breakout lookback) on an upside attempt or Lowest(low[1], breakout lookback) on a downside attempt, stored until a new attempt
Calculation: attempt-zone width = (ATR(ATR lookback), or high - low if ATR is unavailable) × zone multiplier, stored from the attempt bar
Calculation: opposite-pressure rail = continuation level - 2 × attempt-zone width for an upside attempt, or continuation level + 2 × attempt-zone width for a downside attempt
Long: on a confirmed bar, EMA(close, fast lookback) > EMA(close, slow lookback), fast lookback < slow lookback, and high and close > Highest(high[1], breakout lookback)
Short: on a confirmed bar, EMA(close, fast lookback) < EMA(close, slow lookback), fast lookback < slow lookback, and low and close < Lowest(low[1], breakout lookback)
Long: the latest attempt was downside and occurred within the failure window, no trap has yet been recorded for it, close > its continuation level, and 100 × (min(open, close) - low) / (high - low) ≥ wick threshold
Short: the latest attempt was upside and occurred within the failure window, no trap has yet been recorded for it, close < its continuation level, and 100 × (high - max(open, close)) / (high - low) ≥ wick threshold
Long: the latest attempt was downside, has failed, and close > the opposite-pressure rail on a confirmed bar when the previous bar did not have opposite pressure active
Short: the latest attempt was upside, has failed, and close < the opposite-pressure rail on a confirmed bar when the previous bar did not have opposite pressure active
Long: the latest attempt was upside, has not failed, and close > its continuation level + attempt-zone width
Short: the latest attempt was downside, has not failed, and close < its continuation level - attempt-zone width