Calculation: ATR trailing stop = recursively, with previous stop P (0 if unavailable), current close C, previous close C₋₁, and loss L = key value × ATR on the chart timeframe: if C > P and C₋₁ > P, max(P, C − L); else if C < P and C₋₁ < P, min(P, C + L); otherwise C − L if C > P, else C + L
Calculation: Daily close = close of the last completed bar on the higher, daily timeframe
Calculation: Daily SMA = simple moving average of daily closes over a lookback, on the higher, daily timeframe, using the last completed bar
Long: current close > current ATR trailing stop AND previous close ≤ previous ATR trailing stop AND daily close > daily SMA
Short: current close < current ATR trailing stop AND previous close ≥ previous ATR trailing stop AND daily close < daily SMA