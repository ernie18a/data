Long: Chart-timeframe RSI of the selected price > upper threshold
Short: Chart-timeframe RSI of the selected price < lower threshold
Long: RSI on the selected signal bar of the indicator timeframe > upper threshold AND RSI on the preceding indicator-timeframe bar <= upper threshold; the indicator timeframe may be higher or lower than the chart timeframe, and the signal bar may be the last completed bar, an earlier completed bar, or the bar still forming
Short: RSI on the selected signal bar of the indicator timeframe < lower threshold AND RSI on the preceding indicator-timeframe bar >= lower threshold; the indicator timeframe may be higher or lower than the chart timeframe, and the signal bar may be the last completed bar, an earlier completed bar, or the bar still forming
Exit: long, RSI on the selected signal bar of the indicator timeframe < lower threshold; use the same indicator timeframe and signal bar as the entry decisions
Exit: short, RSI on the selected signal bar of the indicator timeframe > upper threshold; use the same indicator timeframe and signal bar as the entry decisions
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance