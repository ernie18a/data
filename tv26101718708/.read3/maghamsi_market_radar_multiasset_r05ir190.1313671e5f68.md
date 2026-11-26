Calculation: momentum = Squeeze Momentum(high, low, close, momentum lookback)
Long: close > EMA(close, trend lookback) AND momentum > 0 OR (close > open AND close > high[1] AND volume > SMA(volume, volume lookback) * volume multiplier) OR (momentum > 0 AND momentum > momentum[1])
Short: close < EMA(close, trend lookback) AND NOT (close > open AND close > high[1] AND volume > SMA(volume, volume lookback) * volume multiplier) AND NOT (momentum > 0 AND momentum > momentum[1])
Calculation: momentum = Linear Regression(close - average((Highest High(momentum length) + Lowest Low(momentum length)) / 2, SMA(close, momentum length)), momentum length)
Calculation: volume surge = close > open AND close > previous bar high AND volume > SMA(volume, volume average length) * volume surge multiplier
Long: (close > EMA(close, trend EMA length) AND momentum > 0) OR volume surge OR (momentum > 0 AND momentum > (previous momentum or zero if unavailable))
Short: close < EMA(close, trend EMA length) AND NOT volume surge AND NOT (momentum > 0 AND momentum > (previous momentum or zero if unavailable))