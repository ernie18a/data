Calculation: Normalized CVD = PercentRank(EMA(((close - open) / (high - low) when high > low, otherwise 0) × min(volume / SMA(volume, volume lookback) when SMA > 0, otherwise 1, volume-relative cap)^volume weight, CVD EMA lookback), CVD normalization lookback), mapped from [0, 100] to [-100, 100]
Calculation: Normalized Momentum = PercentRank(EMA(Normalized CVD - Normalized CVD[momentum lookback], momentum smoothing lookback), momentum normalization lookback), mapped from [0, 100] to [-100, 100]
Calculation: Composite Score = EMA(Normalized CVD × CVD weight + Normalized Momentum × (1 - CVD weight), composite smoothing lookback)
Long: crosses above(Composite Score, 0)
Short: crosses below(Composite Score, 0)