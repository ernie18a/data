Calculation: Effort z-score = (current volume − its moving average) / its standard deviation; if volume is unavailable, use bar range instead of volume.
Calculation: Pivot high/low = a bar whose high/low is the highest/lowest across the configured number of bars before and after it; confirm after those later bars close.
Calculation: Active range = after a selling climax (effort z-score ≥ threshold, bar range ≥ threshold × ATR, low below the prior lookback lows, and close below EMA), the low is the climax low; the first later pivot high at least the minimum ATR height above it sets the range high. For distribution, mirror this: buying climax uses high above prior lookback highs and close above EMA, and the first later pivot low sets the range low.
Long: An active accumulation range has at least one secondary-test pivot low within the configured fraction of the range height above its low; price trades below the range low and closes back above it within the reclaim window (Spring).
Short: An active distribution range has at least one secondary-test pivot high within the configured fraction of the range height below its high; price trades above the range high and closes back below it within the reclaim window (UTAD).
Long: Active accumulation range, no breakout already confirmed, no pending range-edge break, close > range high + configured ATR buffer, and (effort z-score ≥ threshold OR bar range ≥ ATR) (SOS).
Short: Active distribution range, no breakout already confirmed, no pending range-edge break, close < range low − configured ATR buffer, and (effort z-score ≥ threshold OR bar range ≥ ATR) (SOW).
Long: After an accumulation SOS, a later pivot low is at or above the range midpoint (LPS).
Short: After a distribution SOW, a later pivot high is at or below the range midpoint (LPSY).
Exit: long, after an accumulation SOS, close < range midpoint (failed SOS).
Exit: short, after a distribution SOW, close > range midpoint (failed SOW).