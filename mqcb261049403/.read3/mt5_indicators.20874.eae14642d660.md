Calculation: Weighted true range = 2 * sum(TrueRange[n] * (range lookback - n)) / (normalization period * (normalization period + 1)), for n = 0 through range lookback - 1.
Calculation: For each bar series, initialize the boundary to the prior close and the trend state to bullish if the close two bars ago > the prior close, otherwise bearish. On each bar, width = threshold multiplier * weighted true range; if bullish and low < boundary - width, set bearish and boundary = high + spread in price units; if bearish and high + spread in price units > boundary + width, set bullish and boundary = low; if bullish and low > boundary, set boundary = low; if bearish and high + spread in price units < boundary, set boundary = high + spread in price units. Maintain separate state and boundary for each series.
Long: chart trend state = bullish
Short: chart trend state = bearish
Long: chart trend state[signal-bar offset] = bullish AND chart trend state[signal-bar offset + 1] = bearish
Short: chart trend state[signal-bar offset] = bearish AND chart trend state[signal-bar offset + 1] = bullish
Long: trend state on T1 at panel-bar offset = bullish
Short: trend state on T1 at panel-bar offset = bearish
Long: trend state on T2 at panel-bar offset = bullish
Short: trend state on T2 at panel-bar offset = bearish
Long: trend state on T3 at panel-bar offset = bullish
Short: trend state on T3 at panel-bar offset = bearish
Long: trend state on T4 at panel-bar offset = bullish
Short: trend state on T4 at panel-bar offset = bearish
Long: trend state on T5 at panel-bar offset = bullish
Short: trend state on T5 at panel-bar offset = bearish
Long: trend state on T6 at panel-bar offset = bullish
Short: trend state on T6 at panel-bar offset = bearish
Long: trend state on T7 at panel-bar offset = bullish
Short: trend state on T7 at panel-bar offset = bearish
Long: trend state on T8 at panel-bar offset = bullish
Short: trend state on T8 at panel-bar offset = bearish
Long: trend state on T9 at panel-bar offset = bullish
Short: trend state on T9 at panel-bar offset = bearish
Long: trend state on T10 at panel-bar offset = bullish
Short: trend state on T10 at panel-bar offset = bearish