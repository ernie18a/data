Calculation: Breakout trend = initialize down; for each bar, if the previous trend is up and the bar's low is below the lowest low of the preceding lookback bars, set trend to down; then, if trend is down and the bar's high is above the highest high of the preceding lookback bars, set trend to up; otherwise retain trend. Calculate on the chart timeframe for indicator markings and on a configurable higher, lower, or chart timeframe for trading signals, using a configurable completed or still-forming signal bar.
Long: Chart-timeframe breakout trend = up.
Short: Chart-timeframe breakout trend = down.
Long: Signal-bar breakout trend = up AND preceding signal-bar breakout trend = down.
Short: Signal-bar breakout trend = down AND preceding signal-bar breakout trend = up.
Exit: long, signal-bar breakout trend = down OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, signal-bar breakout trend = up OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.