Calculation: Upper Keltner Channel = EMA(close, lookback) + ATR(10) × multiplier
Calculation: Lower Keltner Channel = EMA(close, lookback) − ATR(10) × multiplier
Long: close crosses above Upper Keltner Channel AND volume > its moving average AND close > trend EMA AND RSI > 50 AND ADX > threshold AND position is flat AND time since last entry > cooldown interval
Short: close crosses below Lower Keltner Channel AND volume > its moving average AND close < trend EMA AND RSI < 50 AND ADX > threshold AND position is flat AND time since last entry > cooldown interval
Exit: long, low ≤ entry price − ATR × stop multiplier OR (high > entry price × (1 + breakeven threshold) AND low ≤ entry price) OR (high reaches trailing activation level AND low ≤ trailing stop)
Exit: short, high ≥ entry price + ATR × stop multiplier OR (low < entry price × (1 − breakeven threshold) AND high ≥ entry price) OR (low reaches trailing activation level AND high ≥ trailing stop)