Calculation: EMAAlign = 60 if close > fast EMA AND fast EMA > slow EMA; else 30 if close > fast EMA OR fast EMA > slow EMA; else 0 (fast EMA period shorter than slow EMA period)
Calculation: Slope = least-squares regression line of close over a lookback window, fitted value at the current bar minus fitted value one bar earlier
Calculation: RsiPts = 20 if 50 < RSI < 70; 10 if RSI > 70 OR 30 < RSI < 50; else 0
Calculation: VolPts = 20 if volume / SMA(volume) >= a minimum ratio (> 1); else 0
Calculation: VoltyPts = 20 if ATR / close * 100 is between a lower bound and an upper bound (inclusive); else 0
Calculation: Structure = using the latest confirmed pivot high (PH) and pivot low (PL) (each pivot uses the same number of bars on its left and right, and is known only after the right-side bars complete): +20 if close > PH; else -20 if close < PL; else +15 if low > PL AND PL > PL's value 10 bars earlier; else -15 if high < PH AND PH < PH's value 10 bars earlier; else 0; 0 if no PH or PL exists yet
Calculation: BullScore = clamp(EMAAlign + (20 if Slope > 0 else 0) + RsiPts + VolPts + VoltyPts + max(Structure, 0), 0, 100)
Calculation: BearScore = clamp((100 - EMAAlign) + (20 if Slope < 0 else 0) + (20 - RsiPts) + VolPts + VoltyPts + max(-Structure, 0), 0, 100)
Long: BullScore >= long threshold, evaluated on the closed bar (entry price = that bar's close)
Short: BearScore <= short threshold (short threshold lower than long threshold), evaluated on the closed bar (entry price = that bar's close)
Exit: long, low <= entry price - stop multiple * ATR at the entry bar OR high >= entry price + target multiple * ATR at the entry bar (stop multiple smaller than target multiple)
Exit: short, high >= entry price + stop multiple * ATR at the entry bar OR low <= entry price - target multiple * ATR at the entry bar (stop multiple smaller than target multiple)