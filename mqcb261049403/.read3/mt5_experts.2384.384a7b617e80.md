Calculation: Fast line = MovingAverage(RSI(close, RSI lookback), shorter smoothing lookback, smoothing method, phase, T1, last completed bar)
Calculation: Slow line = MovingAverage(Fast line, longer smoothing lookback, smoothing method, phase, T1, last completed bar)
Long: On each T1 bar close, Fast line[1] > Slow line[1] AND Fast line[0] <= Slow line[0], where [0] is the latest completed bar and [1] the preceding completed bar
Short: On each T1 bar close, Fast line[1] < Slow line[1] AND Fast line[0] >= Slow line[0], where [0] is the latest completed bar and [1] the preceding completed bar
Exit: short, On each T1 bar close, Fast line[1] > Slow line[1]
Exit: long, On each T1 bar close, Fast line[1] < Slow line[1]