Calculation: candle shape ratio = the shape-method parameter’s selected value—CLV, Balance of Power, or (min(open, close) - low - (high - max(open, close))) / (high - low)—when high > low; otherwise 0
Calculation: pressure = clamp(pressure scale × sensitivity × (when volume weighting is enabled, SMA(candle shape ratio × volume, smoothing) / max(SMA(volume, smoothing), denominator floor); otherwise EMA(candle shape ratio, smoothing)), -pressure scale, pressure scale); use values from the last completed chart bar when confirmed bars only is enabled, otherwise from the forming chart bar
Long: pressure > neutral threshold
Long: pressure >= extreme threshold
Long: pressure crosses above 0
Long: EMA(pressure, signal smoothing) >= 0
Short: pressure < -neutral threshold
Short: pressure <= -extreme threshold
Short: pressure crosses below 0
Short: EMA(pressure, signal smoothing) < 0