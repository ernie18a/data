Calculation: Session VWAP = session-resetting volume-weighted average of (high + low + close) / 3
Calculation: ATR = average true range over a lookback
Calculation: Volatility ratio = ATR / simple moving average of close over a longer lookback
Calculation: Adaptive band multiplier = low-volatility multiplier when volatility ratio is below a lower threshold; high-volatility multiplier when above an upper threshold; otherwise normal-volatility multiplier
Calculation: Upper VWAP band = session VWAP + adaptive band multiplier × ATR
Calculation: Lower VWAP band = session VWAP − adaptive band multiplier × ATR
Long: close < lower VWAP band
Short: close > upper VWAP band