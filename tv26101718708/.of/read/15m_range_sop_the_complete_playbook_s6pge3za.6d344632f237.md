Calculation: Range = RangeHigh (highest high) and RangeLow (lowest low) of the bars inside a fixed time-of-day reference window, rebuilt each day. The range is complete when the window ends. The active window runs from the first bar after the window ends until a fixed duration later.
Calculation: TopSweep (bar) = high > RangeHigh AND close <= RangeHigh. BottomSweep (bar) = low < RangeLow AND close >= RangeLow. DoubleSweep = at least one TopSweep AND at least one BottomSweep have occurred in the active window, on or before the current bar.
Calculation: BarDelta = volume * (2*(close-low)/(high-low) - 1), or 0 if high == low.
Calculation: PoolHigh = highest high, and PoolLow = lowest low, over a lookback of bars ending just before the first bar of the reference window.
Long: within the active window AND DoubleSweep AND close > RangeHigh AND BarDelta > 0. Only the first such bar per range; enter at that bar's close.
Short: within the active window AND DoubleSweep AND close < RangeLow AND BarDelta < 0. Only the first such bar per range; enter at that bar's close.
Exit: long, high >= PoolHigh (valid only if PoolHigh > RangeHigh) [final target, full exit]
Exit: long, high >= RangeHigh + (PoolHigh - RangeHigh)/2 (valid only if PoolHigh > RangeHigh) [first target, partial exit]
Exit: long, low <= entry price - fixed stop distance, OR (after the first target was hit) low <= entry price
Exit: short, low <= PoolLow (valid only if PoolLow < RangeLow) [final target, full exit]
Exit: short, low <= RangeLow - (RangeLow - PoolLow)/2 (valid only if PoolLow < RangeLow) [first target, partial exit]
Exit: short, high >= entry price + fixed stop distance, OR (after the first target was hit) high >= entry price