Calculation: Bezier line = the binomially weighted sum of the configured applied price over the current bar and the preceding BPeriod bars, using weights C(BPeriod,i)·T^i·(1−T)^(BPeriod−i) for the bar i bars ago.
Calculation: Bezier-change standard deviation = population standard deviation of the most recent std_period changes in the Bezier line.
Long: On the chart timeframe, the current Bezier line is greater than its value on the preceding bar.
Long: On the chart timeframe, the current Bezier-line change is greater than dK times the Bezier-change standard deviation.
Long: On a higher timeframe, the current still-forming bar’s Bezier line is greater than its value on the preceding bar.
Long: On a higher timeframe, the current still-forming bar’s Bezier-line change is greater than dK times the Bezier-change standard deviation.
Short: On the chart timeframe, the current Bezier line is less than its value on the preceding bar.
Short: On the chart timeframe, the current Bezier-line change is less than −dK times the Bezier-change standard deviation.
Short: On a higher timeframe, the current still-forming bar’s Bezier line is less than its value on the preceding bar.
Short: On a higher timeframe, the current still-forming bar’s Bezier-line change is less than −dK times the Bezier-change standard deviation.