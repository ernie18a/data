Calculation: Smoothed close(tf) = moving average(close, method, lookback, phase) on tf bars; tf is the chart timeframe or T1, and T1 calculations use its current forming bar and are read on chart bars
Calculation: Adjusted smoothed open(tf) = if abs(open - close) <= gap then previous smoothed close(tf), or close on the first bar, else moving average(open, same method, lookback, same phase) on tf bars
Calculation: Trend(tf) = 1 if adjusted smoothed open(tf) < smoothed close(tf), -1 if adjusted smoothed open(tf) > smoothed close(tf), otherwise previous Trend(tf); initialize Trend to 0
Long: Trend(chart)[0] > 0 AND Trend(chart)[1] <= 0
Short: Trend(chart)[0] < 0 AND Trend(chart)[1] >= 0
Long: On chart bars using current forming T1 values, Trend(T1)[0] > 0 AND Trend(T1)[1] <= 0
Short: On chart bars using current forming T1 values, Trend(T1)[0] < 0 AND Trend(T1)[1] >= 0