Calculation: Leading value = (high+low)/2 on the first bar; otherwise 2*((high+low)/2) + (Alpha1-2)*((high[1]+low[1])/2) + (1-Alpha1)*Leading value[1]
Long: Leading value crosses above EMA(close, lookback)
Short: Leading value crosses below EMA(close, lookback)