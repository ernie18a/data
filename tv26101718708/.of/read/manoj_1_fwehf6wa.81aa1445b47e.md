Calculation: EMA of high = exponential moving average of bar highs
Calculation: EMA of low = exponential moving average of bar lows
Calculation: Candle body size = absolute value of close minus open
Long: open < EMA of high AND close > EMA of high AND (VWAP <= close OR (VWAP >= open AND VWAP <= open + Candle body size × touch fraction))
Short: open > EMA of low AND close < EMA of low AND (VWAP >= close OR (VWAP <= open AND VWAP >= open − Candle body size × touch fraction))
Exit: Long, low <= signal bar low OR low <= active trailing stop OR bars since entry >= holding period
Exit: Short, high >= signal bar high OR high >= active trailing stop OR bars since entry >= holding period