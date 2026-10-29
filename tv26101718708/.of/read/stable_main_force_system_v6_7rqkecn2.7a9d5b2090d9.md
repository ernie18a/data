Calculation: OBV = cumulative volume added when close rises from the prior bar, subtracted when close falls, and unchanged when equal; then smoothed with a shorter EMA
Calculation: StopLoss = min(lowest low over a lookback, longer-term EMA) minus an ATR multiple
Calculation: TakeProfit = close plus a multiple of (close - StopLoss)
Long: close > highest high of prior bars over a lookback AND volume > volume moving average times a threshold above 1 AND shorter-term EMA > longer-term EMA AND OBV > its moving average AND close > StopLoss
Exit: long, low <= StopLoss OR high >= TakeProfit