Calculation: VWAP deviation = 100 * (close - VWAP(hlc3)) / VWAP(hlc3)
Long: RSI(close, lookback) > overbought RSI threshold AND VWAP deviation > deviation threshold
Short: RSI(close, lookback) < oversold RSI threshold AND VWAP deviation < -deviation threshold