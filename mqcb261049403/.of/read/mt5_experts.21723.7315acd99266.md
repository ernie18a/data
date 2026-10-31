Calculation: Power-weighted average = sum over lookback n of price[t-k] * (n-k)^p divided by sum of (n-k)^p, for k from 0 to n-1, using a selected OHLC-derived price.
Calculation: Rounded smoothed average = apply a selected moving-average smoothing method and smoothing length to the power-weighted average, then round to the nearest configurable price increment. Calculate on the chart timeframe or a selected higher or lower timeframe; for another timeframe use the last completed bar by default, or the forming bar when configured.
Calculation: Trend = sign of the latest nonzero change in the rounded smoothed average; retain the previous trend when the average is unchanged.
Long: Trend = positive.
Short: Trend = negative.
Exit: long, trend = negative OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, trend = positive OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.