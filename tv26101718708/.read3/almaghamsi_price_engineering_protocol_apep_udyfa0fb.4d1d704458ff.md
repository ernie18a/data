Calculation: Relative price-volume delta = (close - open) / (high - low + spread offset) * volume
Calculation: Absorption cluster = volume > SMA(volume, volume lookback) * volume multiplier AND abs(close - open) < (high - low + spread offset) * body fraction
Long: Absorption cluster AND (Relative price-volume delta > 0 OR close > VWAP)
Short: Absorption cluster AND (Relative price-volume delta < 0 OR close < VWAP)
Long: crossover(EMA(close, shorter lookback), EMA(close, longer lookback))
Short: crossunder(EMA(close, shorter lookback), EMA(close, longer lookback))
Long: crossover(EMA(close, shorter lookback), EMA(close, longer lookback)) AND MFI(hlc3, MFI lookback) >= alert MFI threshold
Short: crossunder(EMA(close, shorter lookback), EMA(close, longer lookback)) AND MFI(hlc3, MFI lookback) <= 100 - alert MFI threshold
Long: MFI(hlc3, MFI lookback) > upper background MFI threshold
Short: MFI(hlc3, MFI lookback) < lower background MFI threshold
Long: MFI(hlc3, MFI lookback) > table MFI threshold
Short: MFI(hlc3, MFI lookback) <= table MFI threshold
Long: Relative price-volume delta > 0
Short: Relative price-volume delta <= 0
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) <= EMA(close, longer lookback)