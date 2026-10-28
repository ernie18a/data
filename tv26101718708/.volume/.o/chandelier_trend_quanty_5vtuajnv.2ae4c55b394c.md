Calculation: ATR span = average true range over a lookback multiplied by a multiplier.
Calculation: Up trailing level = highest high (or close, if measuring from closes) since the latest trend turn minus ATR span; it can only rise while the trend is up.
Calculation: Down trailing level = lowest low (or close, if measuring from closes) since the latest trend turn plus ATR span; it can only fall while the trend is down.
Long: previous trend was down AND close > the down trailing level updated for this bar.
Short: previous trend was up AND close < the up trailing level updated for this bar.
Exit: Long, close < the up trailing level updated for this bar.
Exit: Short, close > the down trailing level updated for this bar.