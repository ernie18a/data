Calculation: LastSwingHigh = most recent non-na PivotHigh(high, swing length)
Calculation: SwingHighActive = true on bars where PivotHigh(high, swing length) is non-na; false after each Long entry; otherwise unchanged
Calculation: LastSwingLow = most recent non-na PivotLow(low, swing length)
Calculation: SwingLowActive = true on bars where PivotLow(low, swing length) is non-na; false after each Short entry; otherwise unchanged
Calculation: BullSweep = SwingLowActive ? (close[1] >= LastSwingLow AND (low[1] < LastSwingLow OR BullSweep[1])) : BullSweep[1]; false after each Long entry
Calculation: BullSweepLow = lowest low[1] since BullSweep last became true, over bars where SwingLowActive AND low[1] < LastSwingLow
Calculation: BearSweep = SwingHighActive ? (close[1] <= LastSwingHigh AND (high[1] > LastSwingHigh OR BearSweep[1])) : BearSweep[1]; false after each Short entry
Calculation: BearSweepHigh = highest high[1] since BearSweep last became true, over bars where SwingHighActive AND high[1] > LastSwingHigh
Calculation: RangeMid = (RangeHigh + RangeLow) / 2, where at each Long entry RangeHigh = LastSwingHigh and RangeLow = (sweep filter on ? BullSweepLow : LastSwingLow), and at each Short entry RangeLow = LastSwingLow and RangeHigh = (sweep filter on ? BearSweepHigh : LastSwingHigh); RangeMid unset before the first entry
Calculation: Trend = 1 at each Long entry, -1 at each Short entry, otherwise unchanged
Long: SwingHighActive AND close[1] > LastSwingHigh AND (full body confirmation off OR open[1] > LastSwingHigh) AND (sweep filter off OR BullSweep) AND (HTF filter off OR close(T1, last completed bar) > SMA(close, lookback, T1, last completed bar)) AND (PD filter off OR RangeMid unset OR close[1] <= RangeMid)
Short: SwingLowActive AND close[1] < LastSwingLow AND (full body confirmation off OR open[1] < LastSwingLow) AND (sweep filter off OR BearSweep) AND (HTF filter off OR close(T1, last completed bar) < SMA(close, lookback, T1, last completed bar)) AND (PD filter off OR RangeMid unset OR close[1] >= RangeMid)
Long: candle coloring on AND Trend = 1
Short: candle coloring on AND Trend = -1