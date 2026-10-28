Calculation: minimum size threshold = configurable pip count × minimum price increment
Calculation: candle body = abs(close − open)
Calculation: upper wick = high − max(open, close)
Calculation: lower wick = min(open, close) − low
Long: close > open AND lower wick ≤ minimum size threshold AND candle body ≥ minimum size threshold AND volume > SMA(volume, lookback)
Short: close < open AND upper wick ≤ minimum size threshold AND candle body ≥ minimum size threshold AND volume > SMA(volume, lookback)