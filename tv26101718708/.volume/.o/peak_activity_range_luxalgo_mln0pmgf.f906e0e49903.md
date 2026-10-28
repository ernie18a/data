Calculation: Active range high/low = high/low of the candle at the latest confirmed volume pivot high, confirmed using equal-length lookbacks before and after that candle
Calculation: Range midpoint = (active range high + active range low) / 2
Long: (Breakout mode AND close > active range high AND previous close ≤ active range high OR Retest mode AND open > active range high AND close < active range high) AND signal state ≠ long
Short: (Breakout mode AND close < active range low AND previous close ≥ active range low OR Retest mode AND open < active range low AND close > active range low) AND signal state ≠ short
