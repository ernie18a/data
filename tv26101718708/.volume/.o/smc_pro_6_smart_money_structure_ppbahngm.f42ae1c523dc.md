Calculation: Last confirmed swing high/low = most recent pivot high/low, each confirmed after the chosen swing lookback bars on both sides
Calculation: Bullish/bearish context = close above/below the long-term EMA, short-term EMA above/below the long-term EMA, and short-term EMA rising/falling
Calculation: Bullish/bearish break confirmation = close beyond the last confirmed swing high/low by at least the chosen ATR multiple; require RSI above/below its midpoint and, when enabled, volume above its moving average; the close-only mode requires only a close beyond the swing
Calculation: Bullish/bearish structure signal = corresponding break confirmation when the last structure signal was not already bullish/bearish; reset that same-direction block when a new swing low/high forms while bias is opposite; update bias and last signal direction when a structure signal occurs
Long: Bullish structure signal
Short: Bearish structure signal
Calculation: Active demand/supply zone = on a confirmed swing low/high, when the distance from that swing to the current high/low exceeds the chosen ATR impulse multiple and bullish/bearish context or a bullish/bearish change-of-character signal holds, create a zone from the swing low to the swing low plus ATR times zone height, or from the swing high minus ATR times zone height to the swing high; replace any prior zone and mark it unused; delete a demand zone if close falls below its bottom, or a supply zone if close rises above its top
Calculation: Zone touch = current bar range overlaps the active zone
Calculation: Bullish/bearish rejection = bullish/bearish candle whose close is above low plus 60% of the bar range / below high minus 60% of the bar range
Calculation: EMA distance = absolute close-to-short-term-EMA distance divided by that EMA
Long: active zone is demand AND bullish context AND bullish bias AND zone touch AND bullish rejection AND EMA distance is below the chosen maximum AND zone is unused
Short: active zone is supply AND bearish context AND bearish bias AND zone touch AND bearish rejection AND EMA distance is below the chosen maximum AND zone is unused