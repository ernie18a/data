Calculation: VFI = EMA of the rolling sum of signed capped volume divided by average volume; assign capped volume a positive or negative sign according to whether hlc3 rose or fell, and assign zero when unchanged. Cap volume at a multiple of average volume.
Calculation: Adaptive baseline = recursively smooth the average of the source’s SMA and VWMA using an alpha derived from its efficiency ratio; the efficiency ratio is absolute net source change over the lookback divided by the sum of absolute one-bar source changes over that lookback.
Calculation: Upper volatility band = adaptive baseline + smoothed ATR buffer; lower volatility band = adaptive baseline − smoothed ATR buffer.
Long: Close > upper volatility band AND VFI > 0 AND last completed higher-timeframe close > its EMA AND same-timeframe VIX close < its EMA.
Short: Close < lower volatility band AND VFI < 0 AND last completed higher-timeframe close < its EMA AND same-timeframe VIX close > its EMA.
Exit: Long, efficiency ratio < chop threshold OR VFI < 0.
Exit: Short, efficiency ratio < chop threshold OR VFI > 0.