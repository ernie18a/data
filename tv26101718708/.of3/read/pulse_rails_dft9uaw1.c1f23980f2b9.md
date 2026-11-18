Calculation: Range normalize(source, lookback) = 50 when highest(source, lookback) equals lowest(source, lookback); otherwise 100 * (source - lowest(source, lookback)) / (highest(source, lookback) - lowest(source, lookback))
Calculation: ATR area = π * ATR(ATR lookback)^2
Calculation: Energy wave = EMA(0.35 * Range normalize(ROC(EMA(OBV(close, volume), OBV EMA lookback), shared ROC lookback), normalization lookback) + 0.35 * Range normalize(ROC(close, shared ROC lookback), normalization lookback) + 0.20 * Range normalize(MACD histogram(close, shorter lookback, longer lookback, signal lookback), normalization lookback) + 0.10 * Range normalize(ATR area, normalization lookback), wave smoothing lookback) - 50
Long: close > Supertrend(ATR factor, ATR lookback) AND close > EMA(close, trend EMA lookback)
Short: close < Supertrend(ATR factor, ATR lookback) AND close < EMA(close, trend EMA lookback)
Long: close > Supertrend(ATR factor, ATR lookback) AND close > EMA(close, trend EMA lookback) AND Energy wave > wave threshold
Short: close < Supertrend(ATR factor, ATR lookback) AND close < EMA(close, trend EMA lookback) AND Energy wave < -wave threshold
Long: close > Supertrend(ATR factor, ATR lookback) AND close > EMA(close, trend EMA lookback) AND Energy wave crosses above EMA(Energy wave, wave smoothing lookback) AND Energy wave > -wave threshold
Short: close < Supertrend(ATR factor, ATR lookback) AND close < EMA(close, trend EMA lookback) AND Energy wave crosses below EMA(Energy wave, wave smoothing lookback) AND Energy wave < wave threshold
Long: Energy wave crosses above zero
Short: Energy wave crosses below zero