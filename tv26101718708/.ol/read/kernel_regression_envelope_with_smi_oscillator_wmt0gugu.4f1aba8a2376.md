Calculation: Rational Quadratic kernel estimate = weighted average of the source over a lookback window using Rational Quadratic kernel weights.
Calculation: Kernel ATR = RMA of true range calculated from the kernel estimates of high, low, and close.
Calculation: Envelope upper = kernel estimate of close + ATR factor × Kernel ATR; Envelope lower = kernel estimate of close − ATR factor × Kernel ATR.
Calculation: SMI = 200 × double-EMA(close − midpoint of the higher-timeframe highest high and lowest low) ÷ double-EMA(higher-timeframe highest high − higher-timeframe lowest low); calculate the extrema over a lookback window on the higher timeframe using its last completed bar, and smooth on the chart timeframe.
Calculation: SMI EMA = EMA of SMI.
Long: close < Envelope lower AND SMI crosses above SMI EMA AND SMI < −50
Short: close > Envelope upper AND SMI crosses below SMI EMA AND SMI > 50
Exit: Long, close crosses above Envelope upper
Exit: Short, close crosses below Envelope lower
Exit: Long, low <= entry price − fixed stop-loss distance in ticks
Exit: Short, high >= entry price + fixed stop-loss distance in ticks