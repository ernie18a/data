Calculation: Price source = a selectable price series from the available bar fields; default to close.
Calculation: VWAP = cumulative sum of typical price times volume divided by cumulative volume, resetting at each trading-session boundary; typical price is (high + low + close) / 3.
Calculation: Mode = the selected intraday or swing mode; in automatic mode, use intraday mode when the chart is intraday and its duration is at or below a threshold, otherwise use swing mode.
Calculation: Base long condition = price source > VWAP AND Parabolic SAR < low AND (ATR filter disabled OR ATR / close * 100 >= minimum ATR percentage) AND (mode = intraday OR absolute value of (price source - Parabolic SAR) / close * 100 >= minimum distance percentage).
Calculation: Long condition = base long condition is true for the current bar in intraday mode, or for at least the configured number of consecutive bars including the current bar in swing mode.
Calculation: Normalized SAR distance = (min(absolute value of (price source - Parabolic SAR) / highest absolute value of (price source - Parabolic SAR) over the normalization lookback, 1)) raised to the configured exponent; use zero when that highest value is zero.
Long: Price source > VWAP.
Short: Price source < VWAP.
Long: Normalized SAR distance > neutral threshold AND Parabolic SAR < price source.
Short: Normalized SAR distance > neutral threshold AND Parabolic SAR > price source.
Long: Long condition = true.
Long: Long condition = true AND position is flat AND (no prior long exit exists OR bars since the last long exit > the cooldown for the selected mode), evaluated on a confirmed bar.
Exit: long, price source < VWAP for the current confirmed bar in intraday mode OR price source < VWAP for at least the configured number of consecutive bars including the current confirmed bar in swing mode.