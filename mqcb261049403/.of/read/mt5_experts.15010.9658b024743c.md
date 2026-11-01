Long: CCI on the selected indicator timeframe > upper threshold AND CCI on the preceding indicator bar <= upper threshold
Short: CCI on the selected indicator timeframe < lower threshold AND CCI on the preceding indicator bar >= lower threshold
Exit: short, CCI on the selected indicator timeframe > upper threshold
Exit: long, CCI on the selected indicator timeframe < lower threshold
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance
Calculation: Selected indicator timeframe CCI = CCI of the configured applied price on the chart timeframe or a configured higher or lower timeframe, using a configured completed bar or the still-forming bar; evaluate completed-bar signals when a new indicator-timeframe bar begins.