Calculation: Confirmed swing high = a bar whose high is greater than the highs over equal left and right lookbacks; available after the right lookback bars complete.
Calculation: Confirmed swing low = a bar whose low is lower than the lows over equal left and right lookbacks; available after the right lookback bars complete.
Calculation: Bullish break source = close in close-confirmation mode, otherwise high.
Calculation: Bearish break source = close in close-confirmation mode, otherwise low.
Long: Current bullish break source > latest confirmed swing high that has not already been broken since confirmation AND previous bar's bullish break source <= that swing high.
Short: Current bearish break source < latest confirmed swing low that has not already been broken since confirmation AND previous bar's bearish break source >= that swing low.