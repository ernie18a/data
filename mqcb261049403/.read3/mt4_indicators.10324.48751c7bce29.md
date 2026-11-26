Calculation: Chart-bar CCI = CCI(applied-price parameter, lookback parameter, T1 bar whose open time exactly matches the chart bar's open time; use the still-forming T1 bar when it is current, otherwise the completed T1 bar)
Calculation: Current upper-band CCI high = maximum chart-bar CCI from the start of the current contiguous sequence of chart bars with chart-bar CCI >= upper CCI threshold through the current chart bar
Calculation: Previous upper-band CCI high = maximum chart-bar CCI in the immediately preceding contiguous sequence of chart bars with chart-bar CCI >= upper CCI threshold
Calculation: Current lower-band CCI low = minimum chart-bar CCI from the start of the current contiguous sequence of chart bars with chart-bar CCI <= lower CCI threshold through the current chart bar
Calculation: Previous lower-band CCI low = minimum chart-bar CCI in the immediately preceding contiguous sequence of chart bars with chart-bar CCI <= lower CCI threshold
Long: Chart-bar CCI >= upper CCI threshold AND Chart-bar CCI = current upper-band CCI high AND Chart-bar CCI >= previous upper-band CCI high
Short: Chart-bar CCI <= lower CCI threshold AND Chart-bar CCI = current lower-band CCI low AND Chart-bar CCI <= previous lower-band CCI low
Long: High - Low >= bar-range threshold