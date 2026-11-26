Calculation: Trend state = previous trend state; set to +1 when close > prior upper threshold, then set to -1 when close < prior lower threshold, on T1 bars at close
Calculation: Upper threshold = (1 + deviation / 100) * MA(close, MA lookback, T1, last completed bar), capped at the prior upper threshold when trend state <= 0
Calculation: Lower threshold = (1 - deviation / 100) * MA(close, MA lookback, T1, last completed bar), floored at the prior lower threshold when trend state > 0
Long: trend state > 0
Short: trend state <= 0
Long: prior trend state < 0 AND trend state > 0
Short: prior trend state > 0 AND trend state < 0
Exit: short, trend state > 0
Exit: long, trend state <= 0