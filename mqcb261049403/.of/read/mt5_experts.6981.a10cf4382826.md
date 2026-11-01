Long: CCI of the selected bar >= 0 AND CCI of the preceding bar < 0 AND position is flat
Short: CCI of the selected bar < 0 AND CCI of the preceding bar >= 0 AND position is flat
Exit: long, CCI of the selected bar < 0 OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, CCI of the selected bar >= 0 OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance
Calculation: Selected bar = configurable bar on the chart timeframe or a higher or lower timeframe; use the forming bar or a completed bar at a configurable lag. CCI uses a configurable OHLC-derived price on that timeframe.