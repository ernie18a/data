Calculation: Smoothed OBV = EMA(5) of cumulative volume, adding volume when close > previous close, subtracting volume when close < previous close, and otherwise adding 0
Calculation: Stop loss = min(lowest low over 10 bars including the current bar, EMA(close, 50)) - 0.5 × ATR(14)
Calculation: Risk per share = close - Stop loss
Calculation: Take profit = close + 2 × Risk per share
Long: close > highest high over the previous 20 bars AND volume > 1.2 × SMA(volume, 20) AND EMA(close, 21) > EMA(close, 50) AND Smoothed OBV > SMA(Smoothed OBV, 20) AND Risk per share > 0
Exit: Long, low <= Stop loss OR high >= Take profit