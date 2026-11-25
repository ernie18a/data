Calculation: PercentChange(current close, reference close) = 100 * (current close / reference close - 1)
Long: PercentChange(each chart bar close, close of the chart bar one index older than the bar at or before that bar's calendar-date start) >= 0
Short: PercentChange(each chart bar close, close of the chart bar one index older than the bar at or before that bar's calendar-date start) <= 0
Long: On chart bars, PercentChange(close of the forming T1 bar, close of the last completed T1 bar) > 0
Short: On chart bars, PercentChange(close of the forming T1 bar, close of the last completed T1 bar) < 0