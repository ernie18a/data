Calculation: Momentum = clamp((HMA(MFI of typical price OR RSI of close) - 50) × 2 × amplification, -100, 100); replace an unavailable HMA with 50 before centering.
Calculation: Price current = EITHER clamp(100 × scale × (HMA(VWMA of close) - HMA(VWMA of close) at a shorter lag) / HMA(VWMA of close) at that lag, -100, 100), using zero if the lagged HMA is unavailable or zero; OR clamp(HMA(signed ADX), -100, 100), using zero if unavailable. Signed ADX equals ADX when positive DI ≥ negative DI and negative ADX otherwise; ADX and DI use the same period.
Calculation: Slope = (current value - value at the slope lookback) / slope lookback. The momentum and price-current slopes use their respective middle-layer HMA lengths and the same lookback.
Calculation: Terrain average = average of two adjacent layers at the selected historical bar; each momentum layer uses a different HMA length, and each price-current layer uses a different HMA length.
Long: Momentum slope > 0 AND price-current slope > 0, using the shorter of the slope lookback and the displayed history length.
Short: Momentum slope < 0 AND price-current slope < 0, using the shorter of the slope lookback and the displayed history length.
Long: Momentum slope > 0 AND price-current slope > 0 AND (previous bar's momentum slope ≤ 0 OR previous bar's price-current slope ≤ 0), using the full slope lookback.
Short: Momentum slope < 0 AND price-current slope < 0 AND (previous bar's momentum slope ≥ 0 OR previous bar's price-current slope ≥ 0), using the full slope lookback.
Long: Momentum terrain average > 0.
Short: Momentum terrain average < 0.
Long: Price-current terrain average ≥ 0 AND average of the absolute values of the two price-current layers > 0.
Short: Price-current terrain average < 0.