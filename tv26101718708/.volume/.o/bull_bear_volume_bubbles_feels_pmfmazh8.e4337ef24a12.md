Calculation: Volume multiple = current bar volume divided by the mean volume of the preceding bars, excluding the current bar
Calculation: Bullish volume = lower-timeframe volume on bars that close above their open, plus half the volume on bars that close unchanged; bearish volume = lower-timeframe volume on bars that close below their open, plus half the volume on unchanged bars. If lower-timeframe data is unavailable, classify the bar as bullish when its close is in the upper half of its range, or when its range is zero and close >= open.
Calculation: Last heavy bull/bear volume price = the typical price (high + low + close) / 3 of the lower-timeframe bar with the greatest volume within the latest heavy bull/bear bar; if lower-timeframe data is unavailable, use the heavy bar's typical price.
Long: Volume multiple >= heavy-volume threshold AND bullish volume >= bearish volume
Long: Close > previous last heavy bear volume price AND previous close <= previous last heavy bear volume price
Short: Volume multiple >= heavy-volume threshold AND bearish volume > bullish volume
Short: Close < previous last heavy bull volume price AND previous close >= previous last heavy bull volume price