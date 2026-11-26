Long: close crosses above the latest confirmed swing PivotHigh(high, longer swing lookback, longer swing lookback), and that pivot has not previously triggered a break
Long: close crosses above the latest confirmed internal PivotHigh(high, shorter internal lookback, shorter internal lookback), that pivot has not previously triggered a break, its level differs from the latest swing pivot high, and (the internal confluence filter is disabled OR high - max(close, open) > min(close, open) - low)
Short: close crosses below the latest confirmed swing PivotLow(low, longer swing lookback, longer swing lookback), and that pivot has not previously triggered a break
Short: close crosses below the latest confirmed internal PivotLow(low, shorter internal lookback, shorter internal lookback), that pivot has not previously triggered a break, its level differs from the latest swing pivot low, and (the internal confluence filter is disabled OR high - max(close, open) < min(close, open) - low)
Long: current swing structure bias is bullish
Short: current swing structure bias is bearish
Long: current internal structure bias is bullish
Short: current internal structure bias is bearish
Long: a newly confirmed pivot low is within equal-level threshold × ATR(ATR lookback) of the prior equal-low pivot
Short: a newly confirmed pivot high is within equal-level threshold × ATR(ATR lookback) of the prior equal-high pivot
Calculation: Order-block volatility = ATR(ATR lookback) or cumulative mean true range, selected by parameter
Calculation: Parsed high = if high - low ≥ volatility multiplier × order-block volatility then low else high
Calculation: Parsed low = if high - low ≥ volatility multiplier × order-block volatility then high else low
Calculation: Bullish order block = parsed high and parsed low of the bar with the lowest parsed low between a bullish pivot and its structure break
Calculation: Bearish order block = parsed high and parsed low of the bar with the highest parsed high between a bearish pivot and its structure break
Long: the selected mitigation source (close or high) exceeds the parsed high of an unmitigated bearish order block
Short: the selected mitigation source (close or low) is below the parsed low of an unmitigated bullish order block
Calculation: T1 body ratio = (close - open) / (open × 100), using the last completed T1 bar
Calculation: FVG threshold = if auto threshold is enabled, 2 × cumulative sum of abs(T1 body ratio) sampled on chart bars when T1 changes, divided by chart bar index; otherwise 0
Long: on a chart bar where T1 changes, the low of the forming T1 bar > high from two T1 bars ago AND the last completed T1 close > that high AND T1 body ratio > FVG threshold
Short: on a chart bar where T1 changes, the high of the forming T1 bar < low from two T1 bars ago AND the last completed T1 close < that low AND -T1 body ratio > FVG threshold