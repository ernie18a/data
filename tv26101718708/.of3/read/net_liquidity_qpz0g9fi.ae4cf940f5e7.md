Calculation: Buy Volume = sum(volume for period_length chart bars in the current cycle where close > open)
Calculation: Sell Volume = sum(volume for period_length chart bars in the current cycle where close < open)
Long: Buy Volume >= Sell Volume at cycle completion
Short: Sell Volume > Buy Volume at cycle completion