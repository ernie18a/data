Calculation: Volume momentum = linear regression of (selected moving average of the projected signed-volume series − longer-period EMA of close); projected signed-volume series = EMA of high + normalized signed-volume deviation × price-range deviation when the signed-volume deviation is positive, otherwise low + that product. Signed volume = cumulative sum of sign(close change) × volume; normalize its deviation from its shorter-period average by its standard deviation, then multiply by the standard deviation of high−low.
Calculation: Trend direction = direction of the adaptive band of volume momentum; the band follows momentum only when it moves beyond its cumulative average deviation from the prior band, scaled by sensitivity.
Calculation: Pivot high/low trackers = highest/lowest volume momentum over a lookback, retained until a new rolling extreme; a pivot is marked when its tracker equals its value two bars earlier and differed from its value three bars earlier.
Calculation: Higher-timeframe volume momentum = the same volume momentum calculation on aggregated higher-timeframe bars, using the value available with lookahead off (completed historical bars; the forming bar in real time).
Long: Trend direction changes from bearish to bullish
Long: Pivot low is marked
Long: Pivot low is marked AND current volume momentum is below its prior value AND trend direction is bearish
Long: Volume > its recent average × spike multiplier AND trend direction is bullish
Long: At least three of the four higher-timeframe volume momentum directions are bullish
Short: Trend direction changes from bullish to bearish
Short: Pivot high is marked
Short: Pivot high is marked AND current volume momentum is above its prior value AND trend direction is bullish
Short: Volume > its recent average × spike multiplier AND trend direction is bearish
Short: At least three of the four higher-timeframe volume momentum directions are bearish