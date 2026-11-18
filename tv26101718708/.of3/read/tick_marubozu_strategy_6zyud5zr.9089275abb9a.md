Calculation: body size = abs(close - open)
Long: close > open AND min(open, close) - low <= minimum size parameter AND body size >= minimum size parameter AND volume > SMA(volume, volume lookback)
Short: close < open AND high - max(open, close) <= minimum size parameter AND body size >= minimum size parameter AND volume > SMA(volume, volume lookback)