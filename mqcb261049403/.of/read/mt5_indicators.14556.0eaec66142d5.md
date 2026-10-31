Calculation: Oscillator = shorter-period moving average of the selected price minus longer-period moving average of the same price, using the same averaging method; its signal line is a separately parameterized moving average of the oscillator.
Calculation: Trend = oscillator minus signal line when that difference is nonzero; otherwise the previous bar's trend, initialized to zero. Calculate this on the chart timeframe and separately on the higher timeframe using its still-forming bar.
Long: Chart-timeframe trend > 0 AND previous chart-timeframe trend <= 0
Short: Chart-timeframe trend < 0 AND previous chart-timeframe trend >= 0
Long: Higher-timeframe trend > 0
Short: Higher-timeframe trend < 0