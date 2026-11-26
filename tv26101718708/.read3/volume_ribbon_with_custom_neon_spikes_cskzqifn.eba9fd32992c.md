Calculation: Buy volume = volume * max(close - low, 0) / (max(close - low, 0) + max(high - close, 0)), or 0 when the denominator is 0
Calculation: Sell volume = volume * max(high - close, 0) / (max(close - low, 0) + max(high - close, 0)), or 0 when the denominator is 0
Calculation: Volume ribbon = selected SMA or EMA(buy volume, volume lookback) - selected SMA or EMA(sell volume, same volume lookback and average type)
Long: (volume >= SMA(volume, volume lookback) * spike threshold AND buy volume > sell volume) OR (volume < SMA(volume, same volume lookback) * spike threshold AND volume ribbon >= 0)
Short: (volume >= SMA(volume, volume lookback) * spike threshold AND buy volume <= sell volume) OR (volume < SMA(volume, same volume lookback) * spike threshold AND volume ribbon < 0)