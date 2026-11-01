Calculation: Trend state = initially bearish; on each indicator bar, set bearish if Williams %R < -100 + threshold, then set bullish if Williams %R > -threshold; otherwise retain the previous state. The indicator uses the chart timeframe, or a configurable higher or lower timeframe using either its last completed bar or its still-forming bar.
Long: Trend state changes from bearish to bullish.
Short: Trend state changes from bullish to bearish.
Exit: long, the latest trend-state change is from bullish to bearish OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, the latest trend-state change is from bearish to bullish OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.