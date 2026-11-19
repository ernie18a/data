Calculation: Trend direction = long on the first bar; otherwise long if close > ATR trailing stop[1], short if close < ATR trailing stop[1], and Trend direction[1] if equal
Calculation: ATR trailing stop = close - stop multiplier * ATR(ATR lookback) on the first bar; otherwise, if Trend direction is long, close - stop multiplier * ATR(ATR lookback) when Trend direction[1] is short, else max(ATR trailing stop[1], close - stop multiplier * ATR(ATR lookback)); if Trend direction is short, close + stop multiplier * ATR(ATR lookback) when Trend direction[1] is long, else min(ATR trailing stop[1], close + stop multiplier * ATR(ATR lookback))
Calculation: ATR-stop oscillator = (close - ATR trailing stop) / ATR(ATR lookback)
Long: ATR-stop oscillator > 0
Short: ATR-stop oscillator < 0
Long: close > ATR trailing stop[1] AND Trend direction[1] = short AND (close-confirmation setting is disabled OR bar is confirmed)
Short: close < ATR trailing stop[1] AND Trend direction[1] = long AND (close-confirmation setting is disabled OR bar is confirmed)
Long: ATR-stop oscillator crosses above its selected moving average over the signal lookback AND (close-confirmation setting is disabled OR bar is confirmed)
Short: ATR-stop oscillator crosses below its selected moving average over the signal lookback AND (close-confirmation setting is disabled OR bar is confirmed)