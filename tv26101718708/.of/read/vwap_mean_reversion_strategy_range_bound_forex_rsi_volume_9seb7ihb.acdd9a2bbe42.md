Calculation: Rolling VWAP = sum(volume × close over the lookback) / sum(volume over the lookback)
Calculation: Volume-weighted absolute deviation = sum(volume × abs(close − rolling VWAP) over the lookback) / sum(volume over the lookback)
Long: Current close < rolling VWAP − 2 × volume-weighted absolute deviation AND prior close ≥ prior lower band AND RSI < oversold threshold AND (volume filter disabled OR current volume ≤ volume moving average × volume multiplier)
Short: Current close > rolling VWAP + 2 × volume-weighted absolute deviation AND prior close ≤ prior upper band AND RSI > overbought threshold AND (volume filter disabled OR current volume ≤ volume moving average × volume multiplier)
Exit: Long, current low ≤ current close × (1 − stop-loss percentage) OR current high ≥ rolling VWAP
Exit: Short, current high ≥ current close × (1 + stop-loss percentage) OR current low ≤ rolling VWAP