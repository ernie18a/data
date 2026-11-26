Calculation: signal = Z-Score(CAGR(close from T1, time from T1, lookback), lookback), evaluated on chart bars using T1 values (last completed historical bar; still-forming realtime bar)
Long: signal <= low threshold
Short: signal >= high threshold
Long: signal >= signal[slope lookback]
Short: signal < signal[slope lookback]