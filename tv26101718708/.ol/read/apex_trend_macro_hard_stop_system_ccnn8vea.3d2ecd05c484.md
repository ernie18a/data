Calculation: Linear-regression momentum = linear regression over the Bollinger Band lookback of close minus the average of (highest high + lowest low)/2 and the simple moving average of close.
Calculation: Long trailing stop = on long entry, highest close over the ATR lookback minus ATR times a multiplier; thereafter, the greater of that value and the previous long trailing stop.
Calculation: Short trailing stop = on short entry, lowest close over the ATR lookback plus ATR times a multiplier; thereafter, the lesser of that value and the previous short trailing stop.
Long: Flat AND close crosses above the upper Bollinger Band AND linear-regression momentum > 0 AND volume > its 20-bar simple moving average times a multiplier AND ADX > a threshold AND close > EMA.
Short: Flat AND close crosses below the lower Bollinger Band AND linear-regression momentum < 0 AND volume > its 20-bar simple moving average times a multiplier AND ADX > a threshold AND close < EMA.
Exit: Long, close crosses below the long trailing stop OR close < EMA.
Exit: Short, close crosses above the short trailing stop OR close > EMA.