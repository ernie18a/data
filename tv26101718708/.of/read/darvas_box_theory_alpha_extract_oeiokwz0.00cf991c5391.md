Calculation: Darvas box ceiling and floor = highest high and lowest low over the box lookback, fixed when a box starts; start a box only when its height is at least ATR times the minimum-height setting and, if rising-box filtering is enabled, its ceiling exceeds the previous box ceiling.
Calculation: ATR = Average True Range over its configured lookback.
Calculation: Breakout above/below box = close above/below the corresponding boundary in Close mode, or high/low above/below it in Wick mode.
Calculation: Volume confirmation = current volume >= its moving-average volume baseline times the configured multiplier; bypass when volume filtering is disabled.
Calculation: Trend confirmation = source price > its trend EMA; bypass when trend filtering is disabled.
Calculation: Base stop = box floor in Box Floor mode, box ceiling in Breached Ceiling mode, or source price - ATR times the configured stop multiplier in ATR mode. Initialize the trailing stop to the base stop; when higher-box trailing is enabled, raise it to the greater of its current value and the base stop on a qualifying higher box.
Long: active box AND breakout above box AND volume confirmation AND trend confirmation AND (no active long position OR active long position AND source price > entry price)
Short: active box AND NOT breakout above box AND breakout below box AND no active position
Exit: long, source price < trailing stop OR breakout below box