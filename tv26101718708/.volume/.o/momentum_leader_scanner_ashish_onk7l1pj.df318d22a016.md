Calculation: EP anchor = most recent bar with close at least the prior bar’s close times (1 + the EP threshold); expire after the maximum anchor age
Calculation: Outperformance since EP = (stock return since EP anchor) − (benchmark return since EP anchor), using closes from the current bar and EP anchor; benchmark bars use the chart timeframe
Calculation: 52-week high = highest high over 252 chart-timeframe bars
Calculation: Low-volume pullback in EMA cloud = EMA9 > EMA21 > EMA50 AND close is between EMA21 × (1 − wick tolerance) and EMA9 × (1 + wick tolerance) AND current volume is at most the volume moving average × pullback volume multiplier
Calculation: Locked trigger = highest high since the EP anchor, locked on the first setup bar and cleared after three consecutive bars without a setup
Long: (EP anchor is active AND outperformance since EP >= minimum outperformance AND close is within the maximum allowed percentage below the 52-week high AND low-volume pullback in EMA cloud) OR (locked trigger is active AND close > locked trigger)
