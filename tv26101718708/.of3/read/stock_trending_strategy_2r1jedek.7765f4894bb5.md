Calculation: V = VWAP(T1 anchor, calculated on chart bars through the still-forming T1 period)
Calculation: E = EMA(source, lookback)
Calculation: H = MACD histogram(source, fast lookback, slow lookback, signal lookback, oscillator MA type, signal MA type)
Long: close > V AND close > E AND H[1] crosses above 0 AND H > H[1]
Short: close < V AND close < E AND H[1] crosses below 0 AND H < H[1]
Exit: long, H crosses below 0