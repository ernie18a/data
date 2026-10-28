Calculation: Relative volume = current volume / simple moving average of volume over a lookback.
Calculation: Trailing stop = for a long trend, the greater of the prior stop and current low minus ATR times a multiplier; for a short trend, the lesser of the prior stop and current high plus ATR times a multiplier. Initialize it to the corresponding current-bar value when a trend starts.
Long: Relative volume ≥ a threshold AND close > open AND close > baseline EMA AND trend state is not bullish
Short: Relative volume ≥ a threshold AND close < open AND close < baseline EMA AND trend state is not bearish
Exit: long, close < trailing stop
Exit: short, close > trailing stop