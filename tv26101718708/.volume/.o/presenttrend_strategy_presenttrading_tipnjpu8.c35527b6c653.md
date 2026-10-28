Calculation: Average true range = simple moving average of true range over a lookback
Calculation: PresentTrend = let upper = low − Average true range × multiplier and lower = high + Average true range × multiplier; when the selected RSI or MFI of the price source is at least 50, use the greater of the prior PresentTrend and upper; otherwise use the lesser of the prior PresentTrend and lower (initial prior value is 0)
Calculation: Bars since long signal = bars elapsed since PresentTrend crossed above its value 2 bars earlier
Calculation: Bars since short signal = bars elapsed since PresentTrend crossed below its value 2 bars earlier
Calculation: Bars since prior-bar long signal = bars elapsed since the long signal shifted back one bar
Calculation: Bars since prior-bar short signal = bars elapsed since the short signal shifted back one bar
Calculation: Trend state = set to long when a long signal occurs and bars since prior-bar long signal > bars since short signal; set to short when a short signal occurs and bars since prior-bar short signal > bars since long signal; otherwise retain the previous state (initial state is neutral)
Long: PresentTrend crosses above its value 2 bars earlier OR (Trend state is long AND trade direction is Long or Both)
Short: PresentTrend crosses below its value 2 bars earlier OR (Trend state is short AND trade direction is Short or Both)
Exit: Long, trade direction is Long AND Trend state is short
Exit: Short, trade direction is Short AND Trend state is long