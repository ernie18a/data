Calculation: micro bullish comparison = EMA(high, emaLen, T1, current still-forming bar, sampled on chart bars) > EMA(high, emaLen, T2, current still-forming bar, sampled on chart bars)
Calculation: micro bearish comparison = EMA(low, emaLen, T1, current still-forming bar, sampled on chart bars) < EMA(low, emaLen, T2, current still-forming bar, sampled on chart bars)
Calculation: fast bullish comparison = EMA(high, emaLen, T3, current still-forming bar, sampled on chart bars) > EMA(high, emaLen, T4, current still-forming bar, sampled on chart bars)
Calculation: fast bearish comparison = EMA(low, emaLen, T3, current still-forming bar, sampled on chart bars) < EMA(low, emaLen, T4, current still-forming bar, sampled on chart bars)
Calculation: bullish alignment = micro bullish comparison AND fast bullish comparison
Calculation: bearish alignment = micro bearish comparison AND fast bearish comparison
Calculation: long signal = crossover(EMA(high, emaLen, T3, current still-forming bar, sampled on chart bars), EMA(high, emaLen, T4, current still-forming bar, sampled on chart bars)) on chart bars AND close > EMA(high, emaLen, T5, current still-forming bar, sampled on chart bars) AND bullish alignment AND (ADX(adxLen, adxLen) on chart bars > adxLevel OR ADX filter disabled) AND (abs(EMA(high, emaLen, T3, current still-forming bar, sampled on chart bars) - EMA(high, emaLen, T4, current still-forming bar, sampled on chart bars)) > ATR(ATR lookback) on chart bars * compressionATR OR compression filter disabled)
Calculation: short signal = crossunder(EMA(low, emaLen, T3, current still-forming bar, sampled on chart bars), EMA(low, emaLen, T4, current still-forming bar, sampled on chart bars)) on chart bars AND close < EMA(low, emaLen, T5, current still-forming bar, sampled on chart bars) AND bearish alignment AND (ADX(adxLen, adxLen) on chart bars > adxLevel OR ADX filter disabled) AND (abs(EMA(high, emaLen, T3, current still-forming bar, sampled on chart bars) - EMA(high, emaLen, T4, current still-forming bar, sampled on chart bars)) > ATR(ATR lookback) on chart bars * compressionATR OR compression filter disabled)
Calculation: long stop = if manual trend hold is enabled and manual stop-stage selects T6, T7, T8, T9, or T10, respectively EMA(low, emaLen, selected T, current still-forming bar, sampled on chart bars); otherwise EMA(low, emaLen, first T in T10, T9, T8, T7, T6 for which close > EMA(high, emaLen, same T, current still-forming bar, sampled on chart bars), falling back to T6)
Calculation: short stop = EMA(high, emaLen, first T in T10, T9, T8, T7, T6 for which close < EMA(high, emaLen, same T, current still-forming bar, sampled on chart bars), falling back to T6)
Long: long signal
Long: long signal AND position side <= 0
Short: short signal
Short: short signal AND position side >= 0 AND manual trend hold disabled
Long: micro bullish comparison
Short: NOT micro bullish comparison AND micro bearish comparison
Long: fast bullish comparison
Short: NOT fast bullish comparison AND fast bearish comparison
Long: bullish alignment
Short: NOT bullish alignment AND bearish alignment
Long: close > EMA(high, emaLen, T2, current still-forming bar, sampled on chart bars) OR close > EMA(high, emaLen, T6, current still-forming bar, sampled on chart bars) OR close > EMA(high, emaLen, T7, current still-forming bar, sampled on chart bars) OR close > EMA(high, emaLen, T8, current still-forming bar, sampled on chart bars) OR close > EMA(high, emaLen, T9, current still-forming bar, sampled on chart bars) OR close > EMA(high, emaLen, T10, current still-forming bar, sampled on chart bars)
Short: close <= EMA(high, emaLen, T2, current still-forming bar, sampled on chart bars) OR close <= EMA(high, emaLen, T6, current still-forming bar, sampled on chart bars) OR close <= EMA(high, emaLen, T7, current still-forming bar, sampled on chart bars) OR close <= EMA(high, emaLen, T8, current still-forming bar, sampled on chart bars) OR close <= EMA(high, emaLen, T9, current still-forming bar, sampled on chart bars) OR close <= EMA(high, emaLen, T10, current still-forming bar, sampled on chart bars)
Exit: long, low <= long stop
Exit: short, high >= short stop
Exit: long, bearish alignment
Exit: short, bullish alignment