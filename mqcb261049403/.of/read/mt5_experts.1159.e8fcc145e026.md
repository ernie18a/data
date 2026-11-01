Calculation: Channel midpoint = (highest high + lowest low) / 2 over a lookback including the evaluated bar; calculate two midpoints with independently configurable shorter and longer lookbacks on an indicator timeframe that may be higher or lower than the chart timeframe. Evaluate the selected indicator bar, which may be the last completed bar or the bar still forming, and its preceding indicator bar.
Long: Shorter-lookback midpoint > longer-lookback midpoint AND preceding shorter-lookback midpoint <= preceding longer-lookback midpoint.
Short: Shorter-lookback midpoint < longer-lookback midpoint AND preceding shorter-lookback midpoint >= preceding longer-lookback midpoint.
Long: Indicator-bar close > maximum of the two midpoints AND preceding indicator-bar close <= preceding maximum of the two midpoints.
Short: Indicator-bar close < minimum of the two midpoints AND preceding indicator-bar close >= preceding minimum of the two midpoints.
Exit: short, shorter-lookback midpoint > longer-lookback midpoint OR indicator-bar close > maximum of the two midpoints.
Exit: long, shorter-lookback midpoint < longer-lookback midpoint OR indicator-bar close < minimum of the two midpoints.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.