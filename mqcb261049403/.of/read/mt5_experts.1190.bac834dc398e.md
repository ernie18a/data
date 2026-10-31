Calculation: Smoothed candle = apply the same moving-average method and length separately to open, high, low, and close.
Long: Chart-timeframe smoothed close > chart-timeframe smoothed open.
Short: Chart-timeframe smoothed close <= chart-timeframe smoothed open.
Long: Signal-bar close > signal-bar smoothed high + breakout distance; the signal bar is a configurable bar on an indicator timeframe that can be higher or lower than the chart timeframe, using the last completed bar or the bar still forming.
Short: Signal-bar close < signal-bar smoothed low - breakout distance, using the same indicator timeframe and signal bar as the long breakout.
Exit: long, the most recent indicator-timeframe bar at or before the signal bar whose close is outside its smoothed high plus breakout distance or smoothed low minus breakout distance has close < smoothed low - breakout distance.
Exit: short, the most recent indicator-timeframe bar at or before the signal bar whose close is outside its smoothed high plus breakout distance or smoothed low minus breakout distance has close > smoothed high + breakout distance.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.