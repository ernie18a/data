Calculation: Long trailing stop = max(Long trailing stop[1], low - ATR(lookback) * stop multiplier), initialized at entry close - ATR(lookback) * stop multiplier
Calculation: Short trailing stop = min(Short trailing stop[1], high + ATR(lookback) * stop multiplier), initialized at entry close + ATR(lookback) * stop multiplier
Long: flat AND RSI(close, RSI lookback) crosses above upper threshold
Short: flat AND RSI(close, RSI lookback) crosses below lower threshold
Exit: long, low <= Long trailing stop OR (take profit enabled AND high >= entry price + ATR(lookback) on entry bar * target multiplier)
Exit: short, high >= Short trailing stop OR (take profit enabled AND low <= entry price - ATR(lookback) on entry bar * target multiplier)