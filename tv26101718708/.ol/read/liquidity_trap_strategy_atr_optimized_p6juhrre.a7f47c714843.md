Calculation: Previous day high = high of the last completed bar of a higher timeframe than the chart timeframe
Calculation: Previous day low = low of the last completed bar of a higher timeframe than the chart timeframe
Long: low < previous day low AND close > previous day low AND no entry has occurred today
Short: high > previous day high AND close < previous day high AND no entry has occurred today
Exit: long, low <= signal-bar low minus ATR-based stop distance OR high >= entry price plus twice the distance from entry price to the stop price OR (high > previous day high AND close < previous day high AND no entry has occurred today)
Exit: short, high >= signal-bar high plus ATR-based stop distance OR low <= entry price minus twice the distance from entry price to the stop price OR (low < previous day low AND close > previous day low AND no entry has occurred today)