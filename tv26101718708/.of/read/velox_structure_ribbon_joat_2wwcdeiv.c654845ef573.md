Calculation: SMEMA = SMA(EMA(source, lookback), lookback)
Calculation: volatility step = SMEMA(high − low, long lookback)
Calculation: first upper band = SMEMA(close, long lookback) + volatility step
Calculation: first lower band = SMEMA(close, long lookback) − volatility step
Calculation: warmup bar index = max(3 × core lookback, range smoothing lookback + 50)
Long: bar index ≥ warmup bar index AND SMEMA(close, core lookback) > prior SMEMA(close, core lookback) AND close > first upper band AND RSI(close, momentum lookback) ≥ minimum RSI threshold AND (volume filter disabled OR volume ≤ 0 OR volume > SMA(volume, 20) × volume multiplier)
Long: bar index ≥ warmup bar index AND SMEMA(close, core lookback) > prior SMEMA(close, core lookback) AND prior SMEMA(close, core lookback) ≤ SMEMA(close, core lookback)[2]
Short: bar index ≥ warmup bar index AND SMEMA(close, core lookback) ≤ prior SMEMA(close, core lookback) AND close < first lower band AND RSI(close, momentum lookback) ≤ 100 − minimum RSI threshold AND (volume filter disabled OR volume ≤ 0 OR volume > SMA(volume, 20) × volume multiplier)
Short: bar index ≥ warmup bar index AND SMEMA(close, core lookback) ≤ prior SMEMA(close, core lookback) AND prior SMEMA(close, core lookback) > SMEMA(close, core lookback)[2]