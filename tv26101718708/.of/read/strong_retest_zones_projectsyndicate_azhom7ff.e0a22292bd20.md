Calculation: Confirmed swing low/high = a pivot low/high confirmed after the configured number of right-side bars, using the configured left-side bars
Calculation: Bullish zone = zone centered on a confirmed swing low; bearish zone = zone centered on a confirmed swing high; zone height is configured as an ATR multiple or price percentage
Calculation: Zone strength = 10 × weighted mean of touch count normalized to its configured full-score count, mean zone volume relative to its moving-average baseline, and mean rejection-wick depth relative to ATR; multiply by the configured idle-decay factor
Calculation: Bullish holding-zone touch = low ≤ bullish zone top AND close > bullish zone top
Calculation: Bearish holding-zone touch = high ≥ bearish zone bottom AND close < bearish zone bottom
Calculation: Bullish flipped-zone retest = high ≥ broken bullish zone bottom AND close < broken bullish zone bottom
Calculation: Bearish flipped-zone retest = low ≤ broken bearish zone top AND close > broken bearish zone top
Calculation: Zone proximity = absolute distance from close to zone midpoint ≤ close × configured proximity percentage
Long: bearish flipped-zone retest AND zone strength ≥ configured visibility threshold OR bullish-zone proximity
Short: bullish flipped-zone retest AND zone strength ≥ configured visibility threshold OR bearish-zone proximity