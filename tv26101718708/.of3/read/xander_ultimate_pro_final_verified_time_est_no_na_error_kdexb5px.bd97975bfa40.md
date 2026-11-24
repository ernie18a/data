Calculation: Bullish trend = EMA(close, fast lookback) > EMA(close, slow lookback) AND close > EMA(close, long-term lookback)
Calculation: Bearish trend = EMA(close, fast lookback) < EMA(close, slow lookback) AND close < EMA(close, long-term lookback)
Calculation: Pivot lookback = max(S/R lookback, minimum pivot lookback) on the longer chart-timeframe class; otherwise S/R lookback
Calculation: Latest confirmed pivot high = most recent PivotHigh(high, pivot lookback, pivot lookback)
Calculation: Latest confirmed pivot low = most recent PivotLow(low, pivot lookback, pivot lookback)
Calculation: Tolerance = close × tolerance multiplier, with separate multipliers for the longer and shorter chart-timeframe classes
Long: Bullish trend
Short: Bearish trend
Long: Bullish trend AND ((low <= EMA(close, fast lookback) AND high >= EMA(close, slow lookback)) OR (latest confirmed pivot low exists AND ABS(low - latest confirmed pivot low) <= tolerance) OR (latest confirmed pivot low exists AND close <= latest confirmed pivot low + 2 × tolerance)) AND StochRSI %K crosses above %D while %K < oversold threshold AND volume > SMA(volume, volume lookback)
Short: Bearish trend AND ((low <= EMA(close, slow lookback) AND high >= EMA(close, fast lookback)) OR (latest confirmed pivot high exists AND ABS(high - latest confirmed pivot high) <= tolerance) OR (latest confirmed pivot high exists AND close >= latest confirmed pivot high - 2 × tolerance)) AND StochRSI %K crosses below %D while %K > overbought threshold AND volume > SMA(volume, volume lookback)