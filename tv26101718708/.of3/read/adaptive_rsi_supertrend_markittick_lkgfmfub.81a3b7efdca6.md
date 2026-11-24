Calculation: ARSI Angle = degrees(arctan((Adaptive RSI(close, ARSI lookback) - Adaptive RSI(close, ARSI lookback)[ARSI lookback]) / ARSI lookback))
Calculation: ARSI Supertrend = initialize bullish with the upper band; each bar set bullish if ARSI > prior line, bearish if ARSI < prior line, otherwise retain prior state; upper band = ARSI + factor * RMA(abs(ARSI - ARSI[1]), ATR lookback); lower band = ARSI - factor * RMA(abs(ARSI - ARSI[1]), ATR lookback); line = max(lower band, prior line) when bullish or min(upper band, prior line) when bearish
Calculation: Filtered ARSI = selected RMA(ARSI, signal lookback), Kalman filter(ARSI, process noise, measurement noise), or recursive LLAMA smoothing initialized to ARSI and updated as prior output + alpha * (ARSI - prior output), where alpha = minimum alpha + efficiency * (maximum alpha - minimum alpha), and efficiency = zero when highest(ARSI, signal lookback) - lowest(ARSI, signal lookback) is zero, otherwise min(abs(ARSI - ARSI[signal lookback]) / (highest(ARSI, signal lookback) - lowest(ARSI, signal lookback)), efficiency cap)
Calculation: Merged Line = the mean of Filtered ARSI and ARSI Supertrend, optionally smoothed by the selected SMA, RMA, double WMA, triple VWMA, or HMA using the merged-line smoothing lookback
Calculation: Regime Score = clamp((ARSI - lower regime ARSI bound) / (upper regime ARSI bound - lower regime ARSI bound) * score component, lower score bound, score component) + clamp(ARSI Angle / regime angle scale * score component + half the score component, lower score bound, score component) + score component when ARSI Supertrend is bullish + score component when close > RMA(close, regime lookback)
Long: ARSI[1] crosses above Merged Line[1] AND (volume filter disabled OR volume >= SMA(volume, volume lookback) * volume multiplier) AND (HTF filter disabled OR Adaptive RSI(close, HTF ARSI lookback, T1, last completed T1 bar) >= ARSI midpoint)
Short: ARSI[1] crosses below Merged Line[1] AND (volume filter disabled OR volume >= SMA(volume, volume lookback) * volume multiplier) AND (HTF filter disabled OR Adaptive RSI(close, HTF ARSI lookback, T1, last completed T1 bar) < ARSI midpoint)
Long: ARSI Supertrend changes from bearish to bullish
Short: ARSI Supertrend changes from bullish to bearish
Long: ARSI Supertrend is bullish
Short: ARSI Supertrend is bearish
Long: ARSI Angle >= bias angle threshold
Short: ARSI Angle <= negative bias angle threshold
Long: Adaptive RSI(close, HTF ARSI lookback, T1, last completed T1 bar) >= ARSI midpoint
Short: Adaptive RSI(close, HTF ARSI lookback, T1, last completed T1 bar) < ARSI midpoint
Long: ARSI Angle > SMA(ARSI Angle, ARSI lookback) AND ARSI >= Merged Line
Short: ARSI Angle < SMA(ARSI Angle, ARSI lookback) AND ARSI <= Merged Line
Long: ARSI >= Merged Line
Short: ARSI < Merged Line
Long: Regime Score >= bull regime threshold
Short: Regime Score < bear regime threshold
Long: Regime Score > bull regime threshold AND ARSI >= upper gradient bound AND ((ARSI Angle > SMA(ARSI Angle, ARSI lookback) AND ARSI >= Merged Line) OR (ARSI Angle < SMA(ARSI Angle, ARSI lookback) AND ARSI <= Merged Line))
Long: ARSI >= upper gradient bound AND ((ARSI Angle > SMA(ARSI Angle, ARSI lookback) AND ARSI >= Merged Line) OR (ARSI Angle < SMA(ARSI Angle, ARSI lookback) AND ARSI <= Merged Line))
Short: ARSI <= lower gradient bound AND ((ARSI Angle > SMA(ARSI Angle, ARSI lookback) AND ARSI >= Merged Line) OR (ARSI Angle < SMA(ARSI Angle, ARSI lookback) AND ARSI <= Merged Line))