Calculation: NY RTH VWAP = volume-weighted average of hlc3 from the start of the current regular session through the current bar.
Calculation: 18:00-to-16:00 VWAP = volume-weighted average of hlc3 from the start of the current 18:00-to-16:00 session through the current bar.
Calculation: EMA trend = fast EMA > middle EMA > slow EMA and each is above its previous-bar value (bullish); reverse all inequalities for bearish. The three EMA lookbacks are progressively longer.
Calculation: Long reclaim state = a close above NY RTH VWAP after either one or two consecutive closes above it, remaining true until two consecutive closes below it or the next regular session; short reclaim state is the reverse.
Calculation: VWAP price cross = close crosses NY RTH VWAP in the configured close-cross mode; in wick-cross mode, the bar spans NY RTH VWAP, the prior close is on the opposite side, and the current close is on the crossed-to side.
Long: NY RTH VWAP price cross upward.
Short: NY RTH VWAP price cross downward.
Long: fast EMA crosses above slow EMA.
Short: fast EMA crosses below slow EMA.
Long: NY RTH VWAP crosses above 18:00-to-16:00 VWAP.
Short: NY RTH VWAP crosses below 18:00-to-16:00 VWAP.
Long: during the configured trade window and regular session, long reclaim state is true, EMA trend is bullish, low <= NY RTH VWAP + touch buffer, close > NY RTH VWAP, and (volume confirmation is disabled or volume > prior-bar volume); the VWAP cross count is below its configured limit.
Short: during the configured trade window and regular session, short reclaim state is true, EMA trend is bearish, high >= NY RTH VWAP - touch buffer, close < NY RTH VWAP, and (volume confirmation is disabled or volume > prior-bar volume); the VWAP cross count is below its configured limit.
Long: while flat, a pending long setup remains valid and the configured trade window, regular session, session-display gate, reclaim state, bullish EMA trend, and VWAP cross-count limit still hold; setup high is exceeded by the entry buffer, and the distance from entry stop to setup low minus stop buffer is within the maximum stop distance.
Short: while flat, a pending short setup remains valid and the configured trade window, regular session, session-display gate, reclaim state, bearish EMA trend, and VWAP cross-count limit still hold; setup low is exceeded downward by the entry buffer, and the distance from setup high plus stop buffer to entry stop is within the maximum stop distance.
Exit: long, price <= setup low - stop buffer OR price >= entry price + profit target.
Exit: short, price >= setup high + stop buffer OR price <= entry price - profit target.