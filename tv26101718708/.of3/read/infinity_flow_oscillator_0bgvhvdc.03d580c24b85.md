Calculation: Volatility ratio = ATR(shorter ATR lookback) / SMA(ATR(shorter ATR lookback), longer ATR baseline lookback)
Calculation: Compression = min(max(100 * (1 - Volatility ratio), 0), 100)
Calculation: Volatility expansion = min(max(100 * (Volatility ratio - 1), -100), 100)
Calculation: Direction = 1 if close >= EMA(close, directional bias lookback), else -1
Calculation: Pressure = EMA((2 * (RMI(price source, RMI lookback, RMI momentum lookback) - 50) * RMI weight + 2 * (MFI(HLC3, MFI lookback) - 50) * MFI weight + min(max(WaveTrend(price source, shorter WaveTrend lookback, longer WaveTrend lookback) / WaveTrend scale, -100), 100) * WaveTrend weight + Volatility expansion * Direction * expansion weight) / (RMI weight + MFI weight + WaveTrend weight + expansion weight), pressure smoothing lookback)
Calculation: Signal = EMA(Pressure, pressure signal lookback)
Long: Pressure crosses above Signal AND Pressure > -strong level
Long: Pressure crosses above strong level
Long: Pressure crosses above extreme level
Long: Compression crosses below compression trigger AND Pressure > 0 AND Pressure > Signal
Long: Pressure >= Signal
Long: Pressure >= 0
Long: Pressure >= weak level
Short: Pressure crosses below Signal AND Pressure < strong level
Short: Pressure crosses below -strong level
Short: Pressure crosses below -extreme level
Short: Compression crosses below compression trigger AND Pressure < 0 AND Pressure < Signal
Short: Pressure < Signal
Short: Pressure < 0
Short: Pressure <= -weak level