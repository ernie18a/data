Calculation: SwingLow = Lowest(low, swing lookback)[1]
Calculation: SwingHigh = Highest(high, swing lookback)[1]
Calculation: BullSweep = low < SwingLow AND close > SwingLow
Calculation: BearSweep = high > SwingHigh AND close < SwingHigh
Calculation: WickPurity = if BullSweep then min(1, (close - low)/(SwingLow - low + tick)) else if BearSweep then min(1, (high - close)/(high - SwingHigh + tick)) else if high > low then (close - low)/(high - low) else flat-bar wick value
Calculation: ZScore(x) = (x - SMA(x, normalization window))/STDEV(x, normalization window) if STDEV(x, normalization window) > 0 else 0
Calculation: ClampZ(z) = min(1, max(0, (z + z offset)/z span))
Calculation: CVDDelta = volume * (2 * close - high - low)/(high - low + tick)
Calculation: OrderFlow = if BullSweep then ZScore(CVDDelta) else if BearSweep then -ZScore(CVDDelta) else abs(ZScore(CVDDelta))
Calculation: Recovery = if BullSweep then min(recovery cap, (close - SwingLow)/(SwingLow - low + tick)) else if BearSweep then min(recovery cap, (SwingHigh - close)/(high - SwingHigh + tick)) else 0
Calculation: SessionValue = if London open hour <= hour(datetime, timezone) < London open hour + London width then London value else if NY open hour <= hour(datetime, timezone) < NY open hour + NY width then NY value else off-peak value
Calculation: BullOBLow = low[impulse count + 1] on the most recent bar where close[i] > open[i] for i = 1 to impulse count AND close[impulse count + 1] < open[impulse count + 1], until a later close below BullOBLow
Calculation: BullOBHigh = high[impulse count + 1] on the same bar as BullOBLow
Calculation: BearOBLow = low[impulse count + 1] on the most recent bar where close[i] < open[i] for i = 1 to impulse count AND close[impulse count + 1] > open[impulse count + 1], until a later close above BearOBHigh
Calculation: BearOBHigh = high[impulse count + 1] on the same bar as BearOBLow
Calculation: OBBonus = order block bonus if (BullSweep AND BullOBLow <= SwingLow <= BullOBHigh) OR (BearSweep AND BearOBLow <= SwingHigh <= BearOBHigh), else 0
Calculation: Score = min(100, 100 * (wick weight * ClampZ(ZScore(WickPurity)) + volume weight * ClampZ(ZScore(volume)) + flow weight * ClampZ(OrderFlow) + recovery weight * ClampZ(ZScore(Recovery)) + session weight * SessionValue) + OBBonus)
Calculation: BullSignal = BullSweep AND Score >= score threshold AND close > EMA(close, trend period)
Calculation: BearSignal = BearSweep AND Score >= score threshold AND close < EMA(close, trend period)
Long: BullSignal AND NOT BullSignal[1]
Long: BullSignal
Long: close > EMA(close, trend period)
Short: BearSignal AND NOT BearSignal[1]
Short: BearSignal
Short: close < EMA(close, trend period)