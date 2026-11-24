Calculation: VWAP = rolling VWAP(hlc3, volume, N−1 prior bars); calculate on chart bars using effective lookback N×(T1 duration/chart-bar duration), clamped to its minimum and maximum, or on T1 bars and map to chart bars using the current possibly forming T1 value or the last completed T1 value; optionally apply three successive EMAs on chart bars with lookback max(2, floor(N/smoothing factor)).
Calculation: σ = sqrt(max(Σ(volume[i]×hlc3[i]²)/Σvolume[i] − VWAP², 0)) over the same prior bars and timeframe mode as VWAP; apply the same optional smoothing.
Calculation: Deviation band(k,s) = VWAP×exp(s×k×σ/VWAP) in geometric mode, otherwise VWAP+s×k×σ; s is +1 for upper and −1 for lower bands, and each ordered band has its own multiplier k shared by its upper and lower bands.
Calculation: z-score = (close−VWAP)/σ.
Calculation: RSI bullish divergence = a confirmed RSI pivot low with left and right pivot length P, where RSI at the pivot exceeds RSI at the preceding pivot low, price low at the pivot is below price low at the preceding pivot, and the preceding pivot event is within the configured minimum and maximum bar range.
Calculation: RSI bearish divergence = a confirmed RSI pivot high with left and right pivot length P, where RSI at the pivot is below RSI at the preceding pivot high, price high at the pivot is above price high at the preceding pivot, and the preceding pivot event is within the configured minimum and maximum bar range.
Long: close > VWAP.
Short: close < VWAP.
Long: crosses above VWAP.
Short: crosses below VWAP.
Long: RSI(close, lookback) < RSI midpoint.
Short: RSI(close, lookback) > RSI midpoint.
Long: z-score < −overextension threshold.
Short: z-score > overextension threshold.
Long: if RSI filtering is enabled, (a low is within tolerance×σ of any VWAP or deviation band, or low ≤ that line and close > that line) OR (extreme bypass is enabled and close is below the outermost lower band), AND within the momentum window RSI ≤ oversold threshold, crosses above oversold threshold, or bullish RSI divergence occurs when divergence is enabled; mark only when this condition becomes true after being false on the preceding chart bar. If RSI filtering is disabled, close crosses above any lower deviation band except the innermost.
Short: if RSI filtering is enabled, (a high is within tolerance×σ of any VWAP or deviation band, or high ≥ that line and close < that line) OR (extreme bypass is enabled and close is above the outermost upper band), AND within the momentum window RSI ≥ overbought threshold, crosses below overbought threshold, or bearish RSI divergence occurs when divergence is enabled; mark only when this condition becomes true after being false on the preceding chart bar. If RSI filtering is disabled, close crosses below any upper deviation band except the innermost.