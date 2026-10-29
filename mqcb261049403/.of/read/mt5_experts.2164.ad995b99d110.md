Calculation: Adaptive lookback = ceiling(long-term lookback / ADX on the bar immediately before the signal bar)
Calculation: Upper threshold = highest high over the adaptive lookback bars, minus (highest high − lowest low) × threshold fraction
Calculation: Lower threshold = lowest low over the adaptive lookback bars, plus (highest high − lowest low) × threshold fraction
Calculation: Trend = +1 when close > upper threshold, −1 when close < lower threshold, otherwise prior trend
Long: close > upper threshold AND prior trend ≠ +1 (signal timeframe, which may be higher or lower than the chart timeframe; last completed bar)
Short: close < lower threshold AND prior trend ≠ −1 (signal timeframe, which may be higher or lower than the chart timeframe; last completed bar)
Exit: long, close < lower threshold AND prior trend ≠ −1 (signal timeframe, which may be higher or lower than the chart timeframe; last completed bar)
Exit: short, close > upper threshold AND prior trend ≠ +1 (signal timeframe, which may be higher or lower than the chart timeframe; last completed bar)