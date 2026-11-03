Calculation: Relative volume = current volume / simple moving average of volume over a lookback
Calculation: Long trailing stop = on each bar in a long trend, the greater of the previous long trailing stop and the bar's low minus ATR times a multiplier; initialize it to the entry bar's low minus ATR times the multiplier
Calculation: Short trailing stop = on each bar in a short trend, the lesser of the previous short trailing stop and the bar's high plus ATR times a multiplier; initialize it to the entry bar's high plus ATR times the multiplier
Long: Relative volume >= spike threshold AND close > open AND close > EMA baseline AND trend is not long
Short: Relative volume >= spike threshold AND close < open AND close < EMA baseline AND trend is not short
Exit: long, close < long trailing stop
Exit: short, close > short trailing stop