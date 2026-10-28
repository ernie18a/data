Calculation: Rolling VWAP = sum(volume × close over lookback) / sum(volume over the same lookback)
Calculation: Volume-weighted absolute deviation = sum(volume × absolute(close − Rolling VWAP)) / sum(volume over the same lookback)
Calculation: Upper band = Rolling VWAP + 2 × Volume-weighted absolute deviation
Calculation: Lower band = Rolling VWAP − 2 × Volume-weighted absolute deviation
Long: close crosses below Lower band AND RSI(close) < oversold threshold AND volume ≤ SMA(volume, lookback) × volume multiplier
Short: close crosses above Upper band AND RSI(close) > overbought threshold AND volume ≤ SMA(volume, lookback) × volume multiplier
Exit: long, low ≤ close × (1 − stop-loss percentage) OR high ≥ Rolling VWAP
Exit: short, high ≥ close × (1 + stop-loss percentage) OR low ≤ Rolling VWAP