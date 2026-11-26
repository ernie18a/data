Calculation: Long stop = low on the long-signal bar × (1 − stop-buffer percentage / 100)
Calculation: Long target = entry price + (entry price − Long stop) × third-target risk/reward multiple
Calculation: Short stop = high on the short-signal bar × (1 + stop-buffer percentage / 100)
Calculation: Short target = entry price − (Short stop − entry price) × third-target risk/reward multiple
Long: close(T1, still-forming bar, sampled on chart bars) > EMA(close, longer lookback, T1, still-forming bar, sampled on chart bars)
Short: close(T1, still-forming bar, sampled on chart bars) <= EMA(close, longer lookback, T1, still-forming bar, sampled on chart bars)
Long: close(T2, still-forming bar, sampled on chart bars) > EMA(close, longer lookback, T2, still-forming bar, sampled on chart bars)
Short: close(T2, still-forming bar, sampled on chart bars) <= EMA(close, longer lookback, T2, still-forming bar, sampled on chart bars)
Long: close(T3, still-forming bar, sampled on chart bars) > EMA(close, longer lookback, T3, still-forming bar, sampled on chart bars)
Short: close(T3, still-forming bar, sampled on chart bars) <= EMA(close, longer lookback, T3, still-forming bar, sampled on chart bars)
Long: close(T4, still-forming bar, sampled on chart bars) > EMA(close, longer lookback, T4, still-forming bar, sampled on chart bars)
Short: close(T4, still-forming bar, sampled on chart bars) <= EMA(close, longer lookback, T4, still-forming bar, sampled on chart bars)
Long: low <= EMA(close, shorter lookback) AND close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback) AND close(T1, still-forming bar, sampled on chart bars) > EMA(close, longer lookback, T1, still-forming bar, sampled on chart bars) AND close(T2, still-forming bar, sampled on chart bars) > EMA(close, longer lookback, T2, still-forming bar, sampled on chart bars) AND volume > SMA(volume, volume lookback)
Short: high >= EMA(close, shorter lookback) AND close < EMA(close, shorter lookback) AND close < EMA(close, longer lookback) AND close(T1, still-forming bar, sampled on chart bars) <= EMA(close, longer lookback, T1, still-forming bar, sampled on chart bars) AND close(T2, still-forming bar, sampled on chart bars) <= EMA(close, longer lookback, T2, still-forming bar, sampled on chart bars) AND volume > SMA(volume, volume lookback)
Exit: long, low <= Long stop OR high >= Long target
Exit: short, high >= Short stop OR low <= Short target