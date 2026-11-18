Calculation: Volume spurt up = volume > SMA(volume, volume-spurt lookback) × volume-spurt multiplier AND close > open
Calculation: Volume spurt down = volume > SMA(volume, volume-spurt lookback) × volume-spurt multiplier AND close < open
Long: Volume spurt up
Short: Volume spurt down
Long: Bullish CISD
Short: Bearish CISD
Long: EMA(close, short lookback) crosses above VWMA(close, volume, medium lookback) AND EMA(close, medium lookback) > VWMA(close, volume, long lookback)
Short: EMA(close, short lookback) crosses below VWMA(close, volume, medium lookback) AND EMA(close, medium lookback) < VWMA(close, volume, long lookback)
Long: EMA(close, short lookback) crosses above VWMA(close, volume, medium lookback) AND EMA(close, medium lookback) > VWMA(close, volume, long lookback) AND Bullish CISD occurs within the CISD recency lookback bars ending at the current bar AND Volume spurt up occurs within the volume-spurt recency lookback bars ending at the current bar
Short: EMA(close, short lookback) crosses below VWMA(close, volume, medium lookback) AND EMA(close, medium lookback) < VWMA(close, volume, long lookback) AND Bearish CISD occurs within the CISD recency lookback bars ending at the current bar AND Volume spurt down occurs within the volume-spurt recency lookback bars ending at the current bar