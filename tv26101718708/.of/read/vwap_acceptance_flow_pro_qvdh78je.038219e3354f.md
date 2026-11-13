Calculation: RollingVWAP = sum(close*volume over N bars) / sum(volume over N bars) (close if volume sum is 0)
Calculation: Dist = (close - RollingVWAP) / ATR
Calculation: Velocity = EMA of (Dist - previous bar Dist), short smoothing
Calculation: AcceptCount = running counter, +1 if close > RollingVWAP else -1 each bar, clamped to a symmetric cap; AcceptNorm = AcceptCount / constant
Calculation: Slope = (RollingVWAP - RollingVWAP k bars ago) / ATR
Calculation: RawFlow = positive-weighted sum of Dist, Velocity, AcceptNorm, Slope (weights ordered Dist > Velocity > AcceptNorm > Slope)
Calculation: ChartFlow = EMA(RawFlow, short length); X5Flow = EMA(RawFlow, medium length, longer than ChartFlow's); X15Flow = EMA(RawFlow, long length, longer than X5Flow's); all on chart timeframe, current bar
Calculation: Trigger = EMA(ChartFlow, very short length, shorter than ChartFlow's length)
Long: ChartFlow crosses above X5Flow
Long: X15Flow > 0 AND X5Flow > 0 AND ChartFlow crosses above Trigger AND ChartFlow > previous bar ChartFlow
Long: X15Flow > 0 AND X5Flow > 0 AND ChartFlow < 0
Short: ChartFlow crosses below X5Flow
Short: X15Flow < 0 AND X5Flow < 0 AND ChartFlow crosses below Trigger AND ChartFlow < previous bar ChartFlow
Short: X15Flow < 0 AND X5Flow < 0 AND ChartFlow > 0