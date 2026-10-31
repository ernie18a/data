Calculation: Anchored momentum of a price series = 100 × (EMA / SMA − 1), with the EMA and SMA using the same lookback; undefined when the SMA is zero.
Long: Anchored momentum of the selected chart-timeframe price > upper threshold.
Short: Anchored momentum of the selected chart-timeframe price <= upper threshold AND anchored momentum of that price < lower threshold.
Long: Chart-timeframe anchored momentum of close > anchored momentum of open.
Short: Chart-timeframe anchored momentum of close < anchored momentum of open.
Long: On the last completed bar of a configurable higher or lower timeframe, anchored momentum of close > anchored momentum of open AND on its preceding bar anchored momentum of close <= anchored momentum of open.
Short: On the last completed bar of a configurable higher or lower timeframe, anchored momentum of close < anchored momentum of open AND on its preceding bar anchored momentum of close >= anchored momentum of open.
Exit: long, anchored momentum of close < anchored momentum of open on the last completed bar of a configurable higher or lower timeframe.
Exit: short, anchored momentum of close > anchored momentum of open on the last completed bar of a configurable higher or lower timeframe.
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.