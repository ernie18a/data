Calculation: Adaptive range = a selectable moving average of the absolute change in a selectable OHLC-derived price source, smoothed again with the same moving average over a lookback of twice the first lookback minus one bar, then multiplied by a range multiplier. Supported averages are EMA, SMA, WMA, HMA, RMA, DEMA, TEMA, VWMA, linear regression moving average, and ALMA.
Calculation: Range filter = the price source while the adaptive range is unavailable; otherwise, use the previous filter value, or the current price source if no previous filter exists. If the source is above that value, take the maximum of that value and source minus adaptive range; otherwise, take the minimum of that value and source plus adaptive range.
Calculation: Trend state = initially neutral; on each completed bar with an available adaptive range, set bullish if the range filter rises, bearish if it falls, or neutral if the optional neutral setting is enabled and the filter has remained flat for at least the configured consecutive-bar threshold; otherwise retain the previous state.
Long: Trend state is bullish.
Long: Trend state changes to bullish.
Short: Trend state is bearish.
Short: Trend state changes to bearish.
Exit: long, range filter falls.
Exit: short, range filter rises.