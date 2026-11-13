Calculation: qADR = SMA over a lookback of ((high / low - 1) * 100), computed on daily bars (daily timeframe is the same as or higher than the chart timeframe), including the daily bar still forming
Calculation: Delta = (daily close - daily open) / (qADR / 100 * daily close), using the daily bar still forming
Long: Delta >= 1
Long: Delta > 0
Short: Delta <= -1
Short: Delta <= 0