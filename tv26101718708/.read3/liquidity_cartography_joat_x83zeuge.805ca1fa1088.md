Calculation: LastSwingHigh = most recent PivotHigh(high, structure length, structure length) value
Calculation: LastSwingLow = most recent PivotLow(low, structure length, structure length) value
Calculation: LowerSweep = (low < low on T1 bars, last completed bar AND close > low on T1 bars, last completed bar) OR (low < low on T2 bars, last completed bar AND close > low on T2 bars, last completed bar)
Calculation: UpperSweep = (high > high on T1 bars, last completed bar AND close < high on T1 bars, last completed bar) OR (high > high on T2 bars, last completed bar AND close < high on T2 bars, last completed bar)
Calculation: SweepSide = 1 if LowerSweep, else -1 if UpperSweep, else 0
Calculation: ActiveSweepSide = most recent nonzero SweepSide among the current bar and the previous confirmation window bars, else 0
Calculation: BodyAverage = SMA(abs(close - open), body length)
Calculation: RVOL = volume / SMA(volume, volume length)
Calculation: TrendEMA = EMA(close, trend length)
Calculation: HTFTrendEMA = EMA(close, trend length) on T3 bars, last completed bar
Calculation: RSIValue = RSI(close, RSI length)
Long: ActiveSweepSide = 1 AND close > LastSwingHigh AND close[1] <= LastSwingHigh AND ((close > open AND abs(close - open) > BodyAverage * displacement multiplier) OR low > high[1]) AND close > TrendEMA AND close > HTFTrendEMA AND RVOL >= RVOL threshold AND RSIValue >= bull RSI floor AND bar time within session window
Long: LowerSweep
Short: ActiveSweepSide = -1 AND close < LastSwingLow AND close[1] >= LastSwingLow AND ((close < open AND abs(close - open) > BodyAverage * displacement multiplier) OR high < low[1]) AND close < TrendEMA AND close < HTFTrendEMA AND RVOL >= RVOL threshold AND RSIValue <= bear RSI ceiling AND bar time within session window
Short: UpperSweep