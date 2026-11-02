Calculation: Trend state = shorter-period Wilder moving average of chart close > longer-period Wilder moving average of chart close; false if either average is unavailable.
Calculation: Hold state = trend state on the first bar; thereafter, retain the previous hold state unless trend state differs from it and at least the minimum number of bars have elapsed since initialization or the last hold-state change, in which case set hold state to trend state.
Long: Hold state = true AND previous hold state = false
Exit: long, hold state = false AND previous hold state = true