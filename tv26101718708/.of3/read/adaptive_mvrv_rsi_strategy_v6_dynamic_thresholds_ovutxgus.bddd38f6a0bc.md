Calculation: MVRV mean = SMA(MVRV close, L) on T2 bars using current T2 values (forming in realtime; last completed historically)
Calculation: MVRV standard deviation = STDEV(MVRV close, L) on T2 bars using current T2 values (forming in realtime; last completed historically)
Calculation: RSI series = RSI(close, R) on T2 bars using current T2 values (forming in realtime; last completed historically)
Calculation: RSI mean = SMA(RSI series, L) on T2 bars using current T2 values (forming in realtime; last completed historically)
Calculation: RSI standard deviation = STDEV(RSI series, L) on T2 bars using current T2 values (forming in realtime; last completed historically)
Calculation: MVRV lower threshold = MVRV mean - MVRV standard deviation * K_MVRV_low
Calculation: MVRV upper threshold = MVRV mean + MVRV standard deviation * K_MVRV_high
Calculation: RSI lower threshold = RSI mean - RSI standard deviation * K_RSI_low
Calculation: RSI upper threshold = RSI mean + RSI standard deviation * K_RSI_high
Long: On chart bars, MVRV close on current T1 bar < MVRV lower threshold OR RSI series on current T2 bar < RSI lower threshold; T1 is shorter than T2, and T1/T2 values are mapped to chart bars (forming in realtime; last completed historically)
Exit: long, on chart bars MVRV close on current T1 bar > MVRV upper threshold OR RSI series on current T2 bar > RSI upper threshold; T1/T2 values are mapped to chart bars (forming in realtime; last completed historically)
Long: Bitcoin MVRV ratio on T1 < SMA(Bitcoin MVRV ratio on T2, P1) - STDEV(Bitcoin MVRV ratio on T2, P1) * P2 AND time >= P4 AND time <= P5
Exit: Long, Bitcoin MVRV ratio on T1 > SMA(Bitcoin MVRV ratio on T2, P1) + STDEV(Bitcoin MVRV ratio on T2, P1) * P3 AND time >= P4 AND time <= P5