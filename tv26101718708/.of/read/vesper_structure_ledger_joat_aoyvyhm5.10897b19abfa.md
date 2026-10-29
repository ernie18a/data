Calculation: Swing high/low = most recent confirmed pivot high/low, using configurable left and right lookbacks
Calculation: Bull/bear break = on a confirmed chart bar, close crosses above the latest swing high / below the latest swing low, respectively (previous close was at or below / at or above that same level)
Calculation: Bull/bear CHoCH = bull/bear break while structure direction is bearish/bullish, respectively, and the opposite-direction BOS count meets the configured reversal threshold; a CHoCH changes structure direction and resets both BOS counts
Calculation: Bull/bear BOS = bull/bear break that is not a bull/bear CHoCH, respectively; a BOS changes structure direction to bullish/bearish, increments its direction's BOS count, and resets the opposite count
Calculation: Bull/bear sweep = on a confirmed chart bar, within the configured lookback from the latest swing low/high, low is below / high is above that swing level, close reclaims / falls back below it, and the excursion is at least the configured ATR multiple
Long: bull BOS OR bull CHoCH OR bull sweep
Short: bear BOS OR bear CHoCH OR bear sweep