Calculation: Normalized z-score = clamp((value - its lookback simple moving average) / its lookback standard deviation, -3, 3) / 3; use 0 when standard deviation is 0
Calculation: Trend score = clamp((shorter-lookback close EMA - longer-lookback close EMA) / ATR, -3, 3) / 3
Calculation: Momentum score = normalized z-score of the close rate of change over its lookback
Calculation: Mean-reversion score = clamp(-(close - close VWMA over the shorter EMA lookback) / ATR, -3, 3) / 3
Calculation: Slope score = normalized z-score of the difference between current and prior one-bar-offset linear regression values of close, using the shorter EMA lookback
Calculation: Scaled score = 7 × (0.20 × trend score + 0.20 × momentum score + 0.10 × mean-reversion score + 0.10 × normalized z-score of volume × sign of momentum score + 0.10 × slope score)
Calculation: Normal stop = max(entry price - stop ATR multiple × ATR, entry price × (1 - hard stop percentage / 100))
Calculation: Runner trigger = entry price × (1 + runner profit percentage / 100)
Long: Scaled score > long score threshold AND shorter-lookback close EMA > longer-lookback close EMA AND close > longer-lookback close EMA
Exit: long, low <= normal stop OR high >= entry price + target ATR multiple × ATR OR (close < shorter-lookback close EMA OR scaled score < exit score threshold)
Exit: long, high >= runner trigger AND low <= entry price × (1 - hard stop percentage / 100)
Exit: long, high >= runner trigger AND higher-timeframe close < higher-timeframe EMA AND higher-timeframe EMA < its value on the prior higher-timeframe bar; use the higher-timeframe bar still forming