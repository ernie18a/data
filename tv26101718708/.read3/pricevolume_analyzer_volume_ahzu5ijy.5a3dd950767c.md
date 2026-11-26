Calculation: spread = high - low
Long: spread < SMA(spread, spread lookback) / threshold AND volume > SMA(volume, volume lookback) * threshold AND close > open AND bar is confirmed
Short: spread < SMA(spread, spread lookback) / threshold AND volume > SMA(volume, volume lookback) * threshold AND close <= open AND bar is confirmed