Calculation: MeanVolume = SMA(volume, VolLength)
Calculation: BarRange = high - low
Calculation: LastPivotLow = PivotLow(low, PivotSpan, PivotSpan) if not NA else LastPivotLow[1]
Calculation: LastPivotHigh = PivotHigh(high, PivotSpan, PivotSpan) if not NA else LastPivotHigh[1]
Calculation: LowSweep = low < LastPivotLow AND close > LastPivotLow AND volume >= MeanVolume
Calculation: LowSweepArmed = PivotLow(low, PivotSpan, PivotSpan) is not NA OR (LowSweepArmed[1] AND NOT LowSweep[1])
Calculation: HighSweep = high > LastPivotHigh AND close < LastPivotHigh AND volume >= MeanVolume
Calculation: HighSweepArmed = PivotHigh(high, PivotSpan, PivotSpan) is not NA OR (HighSweepArmed[1] AND NOT HighSweep[1])
Long: LowSweep AND LowSweepArmed
Short: HighSweep AND HighSweepArmed
Long: BarRange > ATR(high, low, close, ATRLength) * ATRMult AND (min(open, close) - low) / BarRange > WickRatio AND close > open AND abs(close - open) < BodyRatio * BarRange AND volume > MeanVolume
Short: BarRange > ATR(high, low, close, ATRLength) * ATRMult AND (high - max(open, close)) / BarRange > WickRatio AND close < open AND abs(close - open) < BodyRatio * BarRange AND volume > MeanVolume
Long: volume > MeanVolume * VolMult AND close[1] < open[1] AND close > open AND close > close[1] AND (close - low) > CloseRatio * (high - close)
Short: volume > MeanVolume * VolMult AND close[1] > open[1] AND close < open AND close < close[1] AND (high - close) > CloseRatio * (close - low)