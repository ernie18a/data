Calculation: Long stop at entry signal = min(low, EMA(close, mid)) - ATR(lookback) * stop multiplier
Calculation: Short stop at entry signal = max(high, EMA(close, mid)) + ATR(lookback) * stop multiplier
Calculation: Long target at entry signal = close + (close - long stop at entry signal) * reward-to-risk parameter
Calculation: Short target at entry signal = close - (short stop at entry signal - close) * reward-to-risk parameter
Long: close crosses above EMA(close, fast) AND EMA(close, mid) < EMA(close, fast) AND EMA(close, slow) < EMA(close, mid) AND EMA(close, fast) > EMA(close, fast)[slope lookback]
Short: close crosses below EMA(close, fast) AND EMA(close, fast) < EMA(close, mid) AND EMA(close, fast) < EMA(close, slow) AND EMA(close, fast) < EMA(close, fast)[slope lookback]
Exit: long, EMA(close, fast) crosses below EMA(close, mid) OR low <= long stop at entry signal OR (reward-to-risk parameter > 0 AND high >= long target at entry signal)
Exit: short, EMA(close, fast) crosses above EMA(close, mid) OR high >= short stop at entry signal OR (reward-to-risk parameter > 0 AND low <= short target at entry signal)