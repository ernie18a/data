Calculation: MACD = EMA(hl2(T1, current forming bar), shorter lookback) - EMA(hl2(T1, current forming bar), longer lookback), calculated on chart bars using T1 values
Calculation: Signal = SMA(MACD, signal lookback), calculated on chart bars
Long: MACD > Signal
Short: MACD < Signal