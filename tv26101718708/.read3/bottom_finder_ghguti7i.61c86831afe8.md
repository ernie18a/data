Calculation: drawdown percentage = 100 × (highest(high, high lookback) - close) / highest(high, high lookback)
Calculation: rebound percentage = if lowest(low, low lookback) > 0 then 100 × (close - lowest(low, low lookback)) / lowest(low, low lookback), else 0
Calculation: ATR ratio = if ATR(long ATR lookback) > 0 then ATR(short ATR lookback) / ATR(long ATR lookback), else 1
Calculation: volume ratio = if SMA(volume, long volume lookback) > 0 then SMA(volume, short volume lookback) / SMA(volume, long volume lookback), else 1
Calculation: bottom-zone state = drawdown percentage >= minimum drawdown percentage AND rebound percentage <= maximum rebound percentage AND ((zone mode = OR AND (ATR ratio <= ATR contraction threshold OR volume ratio <= volume dryness threshold)) OR (zone mode = AND AND ATR ratio <= ATR contraction threshold AND volume ratio <= volume dryness threshold))
Long: bottom-zone state
Long: bottom-zone state AND NOT bottom-zone state[1]
Long: bottom-zone state AND bars-since(close crosses above SMA(close, moving-average lookback)) <= confirmation window AND bars-since(volume >= SMA(volume, long volume lookback) × volume-spike multiplier) <= confirmation window AND close > open AND bars-since(RSI(close, RSI lookback) crosses above RSI threshold) <= max(confirmation window + RSI window extension, minimum RSI window)