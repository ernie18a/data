Calculation: High slope = (newer of the two latest confirmed PivotHigh(high, pivot lookback, pivot lookback) values - older value) / (newer pivot-high bar index - older pivot-high bar index)
Calculation: Low slope = (newer of the two latest confirmed PivotLow(low, pivot lookback, pivot lookback) values - older value) / (newer pivot-low bar index - older pivot-low bar index)
Calculation: Upper boundary(x) = older of the two latest confirmed pivot highs + High slope * (x - older pivot-high bar index)
Calculation: Lower boundary(x) = older of the two latest confirmed pivot lows + Low slope * (x - older pivot-low bar index)
Calculation: Wedge start bar = earlier of the older pivot-high and older pivot-low bar indices
Calculation: Wedge duration = current chart bar index - Wedge start bar
Calculation: Initial width = Upper boundary(Wedge start bar) - Lower boundary(Wedge start bar)
Calculation: Current width = Upper boundary(current chart bar) - Lower boundary(current chart bar)
Calculation: Wedge geometry = Current width > 0 AND (Initial width - Current width) / Initial width >= minimum contraction fraction AND Initial width >= ATR(shared ATR lookback) * minimum wedge-height multiple AND Wedge duration >= pivot lookback AND Wedge duration <= maximum wedge duration
Calculation: Rising wedge shape = two latest confirmed pivot highs and lows exist AND both newer pivot bars follow their respective older pivot bars AND High slope > 0 AND Low slope > 0 AND Low slope > High slope * convergence strictness AND Wedge geometry
Calculation: Falling wedge shape = two latest confirmed pivot highs and lows exist AND both newer pivot bars follow their respective older pivot bars AND High slope < 0 AND Low slope < 0 AND High slope < Low slope * convergence strictness AND Wedge geometry
Calculation: Breakout filters = (volume confirmation disabled OR volume unavailable OR volume > SMA(volume, volume-average lookback) * volume multiplier) AND (breakout-size filter disabled OR abs(close - open) >= ATR(shared ATR lookback) * minimum breakout-candle-size multiple)
Long: forming-wedge preview enabled AND Falling wedge shape AND NOT (close > Upper boundary(current chart bar) AND close[1] <= Upper boundary(previous chart bar))
Long: Falling wedge shape AND close > Upper boundary(current chart bar) AND close[1] <= Upper boundary(previous chart bar) AND Breakout filters AND (EMA trend filter disabled OR close > EMA(close, EMA lookback))
Short: forming-wedge preview enabled AND Rising wedge shape AND NOT (close < Lower boundary(current chart bar) AND close[1] >= Lower boundary(previous chart bar))
Short: Rising wedge shape AND close < Lower boundary(current chart bar) AND close[1] >= Lower boundary(previous chart bar) AND Breakout filters AND (EMA trend filter disabled OR close < EMA(close, EMA lookback))