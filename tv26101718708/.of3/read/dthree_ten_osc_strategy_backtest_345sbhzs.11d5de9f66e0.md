Calculation: MACD = EMA(hl2(T1, bar still forming), shorter lookback, chart bars) - EMA(hl2(T1, bar still forming), longer lookback, chart bars)
Calculation: MACD signal = SMA(MACD, signal lookback, chart bars)
Long: (reversal mode is off AND MACD > MACD signal) OR (reversal mode is on AND MACD < MACD signal) OR (MACD = MACD signal AND position is long)
Short: (reversal mode is off AND MACD < MACD signal) OR (reversal mode is on AND MACD > MACD signal) OR (MACD = MACD signal AND position is short)