Calculation: daily_bars = daily bars aggregated from the data; the chart timeframe is equal to or higher than daily; use the last completed daily bar at each chart bar
Calculation: scale(x, lo, hi) = clip((x - lo) / (hi - lo) * 100, 0, 100), with fixed lo < hi per metric
Calculation: SMA_short, SMA_mid, SMA_long = simple moving averages of daily close, with length SMA_short < SMA_mid < SMA_long. SMA_long is about 200 weeks expressed in days. SMA_mid is about 1 year
Calculation: SMA_ref = a daily SMA of close whose length is between SMA_short and SMA_mid
Calculation: PL = power-law fair value = 10^(a + b*log10(days since Bitcoin genesis)), with fixed fitted a and b, b > 0
Calculation: metrics (each on daily_bars, each NaN until enough history) = [scale(close/SMA_ref), scale(SMA_short/(2*SMA_mid)), scale(close/SMA_long), scale(close/SMA_mid), scale(daily RSI of close), scale(close/PL)]
Calculation: score = SMA over a smoothing window of (mean of the non-NaN metrics); a bar with no available metric gives NaN
Long: score crosses below the lower threshold (previous score >= lower threshold AND current score < lower threshold)
Short: score crosses above the upper threshold (previous score <= upper threshold AND current score > upper threshold); the upper threshold is greater than the lower threshold