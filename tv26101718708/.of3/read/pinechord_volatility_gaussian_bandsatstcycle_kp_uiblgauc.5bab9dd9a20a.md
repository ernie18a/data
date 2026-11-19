Calculation: Medium-cycle top = nz(RMA(source, max(1, floor(medium cycle length / 2)))[floor(medium cycle length / 4)], source) + medium-cycle multiplier * ATR(max(1, floor(medium cycle length / 2)))
Calculation: Medium-cycle bottom = nz(RMA(source, max(1, floor(medium cycle length / 2)))[floor(medium cycle length / 4)], source) - medium-cycle multiplier * ATR(max(1, floor(medium cycle length / 2)))
Calculation: Long Supertrend stop level = first Supertrend line (its own ATR lookback and factor) - Renko box size * stop-loss bricks
Calculation: Short Supertrend stop level = first Supertrend line (its own ATR lookback and factor) + Renko box size * stop-loss bricks
Long: first Supertrend direction is bullish AND second Supertrend direction is bullish
Short: first Supertrend direction is bearish AND second Supertrend direction is bearish
Long: close crosses above medium-cycle top + long-entry offset AND position is flat or short
Short: close crosses below medium-cycle bottom - short-entry offset AND position is flat or long
Exit: Long, close crosses below long Supertrend stop level OR close >= long Supertrend stop level
Exit: Short, close crosses above short Supertrend stop level OR close >= short Supertrend stop level
Exit: Long, hard-stop distance > 0 AND low <= highest high since long entry - absolute hard-stop distance
Exit: Short, hard-stop distance > 0 AND high >= lowest low since short entry + absolute hard-stop distance