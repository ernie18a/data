Calculation: Delta = 0 if volume is unavailable; otherwise volume × ((close - open) / max(high - low, minimum price increment))
Calculation: Delta threshold = EMA(abs(Delta), delta threshold lookback) × delta threshold multiplier
Calculation: Impulse = abs(close - open) > EMA(abs(close - open), body lookback) × body multiplier AND ATR(fast lookback) > ATR(longer lookback) × range multiplier, where the fast lookback is shorter than the longer lookback
Calculation: Long score = normal score weight for each true condition: Delta > Delta threshold; EMA(Delta, flow lookback) > 0; volume scoring enabled AND volume > SMA(volume, volume average lookback) × volume multiplier AND Delta > 0; trend scoring enabled AND close > EMA(close, trend lookback); Supertrend scoring enabled AND Supertrend(ATR lookback, factor).direction[1] < 0. Add impulse score weight if Impulse AND close > open. Subtract chop penalty weight if chop penalty enabled AND CHOP(chop lookback, minimum price increment) > chop threshold
Calculation: Short score = normal score weight for each true condition: Delta < -Delta threshold; EMA(Delta, flow lookback) < 0; volume scoring enabled AND volume > SMA(volume, volume average lookback) × volume multiplier AND Delta < 0; trend scoring enabled AND close < EMA(close, trend lookback); Supertrend scoring enabled AND Supertrend(ATR lookback, factor).direction[1] > 0. Add impulse score weight if Impulse AND close < open. Subtract chop penalty weight if chop penalty enabled AND CHOP(chop lookback, minimum price increment) > chop threshold
Long: Delta >= 0
Short: Delta < 0
Long: close > EMA(close, trend lookback)
Short: close <= EMA(close, trend lookback)
Long: Supertrend(ATR lookback, factor).direction < 0
Short: Supertrend(ATR lookback, factor).direction >= 0
Long: Supertrend(ATR lookback, factor).direction[1] < 0
Short: Supertrend(ATR lookback, factor).direction[1] >= 0
Long: Long score > Short score
Short: Short score > Long score
Long: Long score >= entry score threshold
Short: Long score < entry score threshold AND Short score >= entry score threshold
Short: Short score >= strong score threshold AND Short score > Long score, where the strong score threshold is greater than the entry score threshold
Long: Supertrend(ATR lookback, factor).direction[1] > 0 AND Supertrend(ATR lookback, factor).direction < 0
Short: Supertrend(ATR lookback, factor).direction[1] < 0 AND Supertrend(ATR lookback, factor).direction > 0
Long: Supertrend(ATR lookback, factor).direction[1] < 0 AND Supertrend(ATR lookback, factor).direction <= 0
Short: NOT (Supertrend(ATR lookback, factor).direction[1] > 0 AND Supertrend(ATR lookback, factor).direction < 0) AND NOT (Supertrend(ATR lookback, factor).direction[1] < 0 AND Supertrend(ATR lookback, factor).direction > 0) AND Supertrend(ATR lookback, factor).direction[1] >= 0