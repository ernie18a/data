Calculation: Upper and lower bands = Bollinger Bands(close, band lookback, band deviation, band shift) on the chart timeframe or T1, using the selected bar shift; values are sampled on chart bars, and the T1 bar may be forming or completed according to the shift
Calculation: EMA = EMA(close, same band lookback, same band shift) on the same selected timeframe and bar shift; values are sampled on chart bars, and the T1 bar may be forming or completed according to the shift
Calculation: Long stop = lower band assigned to the pending long order; thereafter raise it to the selected trailing source (EMA or lower band) only when close > entry price AND close > lower band AND selected source > prior stop; otherwise retain prior stop
Calculation: Short stop = upper band assigned to the pending short order; thereafter lower it to the selected trailing source (EMA or upper band) only when close < entry price AND close < upper band AND selected source < prior stop; otherwise retain prior stop
Long: hour(datetime) > start-hour parameter AND hour(datetime) < end-hour parameter AND upper band > close AND lower band < close
Short: hour(datetime) > start-hour parameter AND hour(datetime) < end-hour parameter AND upper band > close AND lower band < close
Exit: long, low <= Long stop OR high >= entry price + target-distance parameter 1 in points
Exit: long, low <= Long stop OR high >= entry price + target-distance parameter 2 in points
Exit: long, low <= Long stop OR high >= entry price + target-distance parameter 3 in points
Exit: short, high >= Short stop OR low <= entry price - target-distance parameter 1 in points
Exit: short, high >= Short stop OR low <= entry price - target-distance parameter 2 in points
Exit: short, high >= Short stop OR low <= entry price - target-distance parameter 3 in points