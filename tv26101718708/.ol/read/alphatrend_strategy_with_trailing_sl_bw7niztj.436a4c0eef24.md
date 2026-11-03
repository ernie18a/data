Calculation: ATR = simple moving average of true range over a lookback
Calculation: AlphaTrend = when RSI of the selected source is at least 50 with volume data disabled, or MFI of typical price is at least 50 otherwise, the greater of the previous AlphaTrend and low minus ATR; otherwise, the lesser of the previous AlphaTrend and high plus ATR
Calculation: Long trailing stop = highest close-based stop since entry, where each stop is close × (1 − trailing percentage)
Calculation: Short trailing stop = lowest close-based stop since entry, where each stop is close × (1 + trailing percentage)
Long: AlphaTrend crosses above its value two bars earlier
Short: AlphaTrend crosses below its value two bars earlier
Exit: long, trailing stop is enabled AND low is at or below the long trailing stop
Exit: short, trailing stop is enabled AND high is at or above the short trailing stop