Calculation: Bullish volume divergence = on a chart bar confirming both Pivot low(low, pivot strength, pivot strength) and Pivot low(volume, pivot strength, pivot strength), compare both pivot values with those from the preceding chart bar confirming both pivot lows; price lower and volume higher, OR price higher and volume lower
Calculation: Bearish volume divergence = on a chart bar confirming both Pivot high(high, pivot strength, pivot strength) and Pivot high(volume, pivot strength, pivot strength), compare both pivot values with those from the preceding chart bar confirming both pivot highs; price higher and volume lower, OR price lower and volume higher
Calculation: Dynamic volatility multiplier = max(lower clamp, min(upper clamp, SMA(ATR(volatility lookback), volatility averaging lookback) / ATR(volatility lookback)))
Calculation: Volume baseline = SMA(volume, volume baseline lookback)
Calculation: Volume spike = volume > Volume baseline * spike multiplier * Dynamic volatility multiplier
Calculation: Volume climax = volume > Volume baseline * climax multiplier * Dynamic volatility multiplier
Calculation: Volume absorption = NOT Volume climax AND volume > Volume baseline * absorption multiplier * Dynamic volatility multiplier AND high - low < ATR(volatility lookback) * absorption range fraction
Calculation: Volume exhaustion = NOT Volume climax AND NOT Volume absorption AND volume > Volume baseline * exhaustion multiplier * Dynamic volatility multiplier AND high - low < ATR(volatility lookback) * exhaustion range fraction
Calculation: Adaptive volume average = ALMA(volume, adaptive lookback, ALMA offset, ALMA sigma) when adaptive averaging is selected, otherwise SMA(volume, adaptive lookback)
Calculation: Higher-timeframe volume alignment = on chart bars using the T1 volume and SMA(volume, T1 volume lookback) from the latest T1 bar with lookahead off (last completed historically; current forming bar in real time), T1 volume > its SMA
Calculation: Bullish filter alignment = (EMA filter disabled OR close > EMA(close, EMA lookback)) AND (volume filter disabled OR volume > SMA(volume, volume filter lookback)) AND (ATR filter disabled OR high - low > ATR(ATR filter lookback) * ATR multiplier) AND (wick filter inactive OR (close > open AND close - low > (high - low) * bullish wick fraction)) AND (higher-timeframe filter disabled OR Higher-timeframe volume alignment)
Calculation: Bearish filter alignment = (EMA filter disabled OR close < EMA(close, EMA lookback)) AND (volume filter disabled OR volume > SMA(volume, volume filter lookback)) AND (ATR filter disabled OR high - low > ATR(ATR filter lookback) * ATR multiplier) AND (wick filter inactive OR (close < open AND high - close > (high - low) * bearish wick fraction)) AND (higher-timeframe filter disabled OR Higher-timeframe volume alignment)
Long: Bullish volume divergence
Short: Bearish volume divergence
Long: Bullish volume divergence AND Bullish filter alignment
Short: Bearish volume divergence AND Bearish filter alignment
Long: Bullish filter alignment
Short: Bearish filter alignment
Long: Volume spike AND close >= open
Short: Volume spike AND close < open
Long: Bullish volume divergence AND Bullish filter alignment AND (Volume climax OR Volume absorption OR (Volume spike AND close >= open))
Short: Bearish volume divergence AND Bearish filter alignment AND (Volume climax OR Volume absorption OR (Volume spike AND close < open))
Long: close < open AND volume > Adaptive volume average AND close > low + (high - low) * accumulation close fraction AND NOT Volume climax AND NOT Volume absorption AND NOT Volume exhaustion AND NOT (Volume spike AND close >= open) AND NOT (Volume spike AND close < open)
Short: close > open AND volume > Adaptive volume average AND close < low + (high - low) * distribution close fraction AND NOT Volume climax AND NOT Volume absorption AND NOT Volume exhaustion AND NOT (Volume spike AND close >= open) AND NOT (Volume spike AND close < open)