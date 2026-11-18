Calculation: Close(T) = close on T bars, sampled on chart bars using the current T bar in realtime and the last completed T bar historically
Calculation: EMA(T) = EMA(close, EMA lookback) on T bars, sampled on chart bars using the current T bar in realtime and the last completed T bar historically
Calculation: SMA(T) = SMA(close, SMA lookback) on T bars, sampled on chart bars using the current T bar in realtime and the last completed T bar historically
Long: Close(T1) > EMA(T1) AND Close(T1) > SMA(T1) AND EMA(T1) > SMA(T1)
Long: Close(T2) > EMA(T2) AND Close(T2) > SMA(T2) AND EMA(T2) > SMA(T2)
Long: Close(T3) > EMA(T3) AND Close(T3) > SMA(T3) AND EMA(T3) > SMA(T3)
Long: Close(T4) > EMA(T4) AND Close(T4) > SMA(T4) AND EMA(T4) > SMA(T4)
Long: Close(T5) > EMA(T5) AND Close(T5) > SMA(T5) AND EMA(T5) > SMA(T5)
Long: PivotLow(low, pivot lookback, pivot lookback) is not na
Short: Close(T1) < EMA(T1) AND Close(T1) < SMA(T1) AND EMA(T1) < SMA(T1)
Short: Close(T2) < EMA(T2) AND Close(T2) < SMA(T2) AND EMA(T2) < SMA(T2)
Short: Close(T3) < EMA(T3) AND Close(T3) < SMA(T3) AND EMA(T3) < SMA(T3)
Short: Close(T4) < EMA(T4) AND Close(T4) < SMA(T4) AND EMA(T4) < SMA(T4)
Short: Close(T5) < EMA(T5) AND Close(T5) < SMA(T5) AND EMA(T5) < SMA(T5)
Short: PivotHigh(high, pivot lookback, pivot lookback) is not na