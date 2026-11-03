Calculation: Range trend = for each bar, let H be the highest high and L the lowest low over a lookback including that bar, and let f be a risk-dependent fraction. Set the trend to -1 if close < L + f × (H - L), then to +1 if close > H - f × (H - L); otherwise retain the previous trend. Initialize the trend to 0.
Calculation: Smoothed filter = Jurik moving average of the FATL digital filter applied to a selected OHLC-derived price, rounded to a configurable price increment.
Calculation: Filter direction = +1 when the smoothed filter rises, -1 when it falls, and the previous direction when it is unchanged; initialize to 0.
Calculation: Evaluate both calculations on chart bars for indicator markings. For each trading system, independently evaluate its calculation on the selected chart, higher, or lower timeframe, using a configurable signal bar: the bar still forming or a specified completed bar. Compare it with the immediately preceding bar of that same timeframe.
Long: Range trend = +1 OR filter direction = +1
Short: Range trend = -1 OR filter direction = -1
Exit: long, range trend = -1 OR filter direction = -1 OR low <= entry price - stop distance OR high >= entry price + profit distance
Exit: short, range trend = +1 OR filter direction = +1 OR high >= entry price + stop distance OR low <= entry price - profit distance