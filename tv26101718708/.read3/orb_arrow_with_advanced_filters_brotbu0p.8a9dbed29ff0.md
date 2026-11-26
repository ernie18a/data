Calculation: opening-range high = highest high during the opening range
Calculation: opening-range low = lowest low during the opening range
Long: close crosses above opening-range high AND volume > SMA(volume, lookback) AND ATR(lookback) > threshold AND RSI(close, lookback) < upper threshold
Short: close crosses below opening-range low AND volume > SMA(volume, lookback) AND ATR(lookback) > threshold AND RSI(close, lookback) > lower threshold