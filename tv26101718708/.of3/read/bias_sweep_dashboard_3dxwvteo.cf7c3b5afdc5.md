Calculation: Latest swing high = most recent confirmed PivotHigh(high, swing lookback, swing lookback) on the evaluated bars
Calculation: Latest swing low = most recent confirmed PivotLow(low, swing lookback, swing lookback) on the evaluated bars
Calculation: Latest bearish FVG upper boundary = low[FVG offset] from the most recent bar where high < low[FVG offset]
Calculation: Latest bullish FVG lower boundary = high[FVG offset] from the most recent bar where low > high[FVG offset]
Long: Latest swing low exists AND low < Latest swing low AND close > Latest swing low
Long: On chart bars using the still-forming T1 bar, Latest swing low(T1) exists AND low(T1, still-forming bar) < Latest swing low(T1) AND close(T1, still-forming bar) > Latest swing low(T1); T1 is longer than T2
Long: On chart bars using the still-forming T2 bar, Latest swing low(T2) exists AND low(T2, still-forming bar) < Latest swing low(T2) AND close(T2, still-forming bar) > Latest swing low(T2)
Long: On chart bars, Latest bearish FVG upper boundary exists AND close > Latest bearish FVG upper boundary AND close[previous-close lookback] < Latest bearish FVG upper boundary
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Short: Latest swing high exists AND high > Latest swing high AND close < Latest swing high
Short: On chart bars using the still-forming T1 bar, Latest swing high(T1) exists AND high(T1, still-forming bar) > Latest swing high(T1) AND close(T1, still-forming bar) < Latest swing high(T1); T1 is longer than T2
Short: On chart bars using the still-forming T2 bar, Latest swing high(T2) exists AND high(T2, still-forming bar) > Latest swing high(T2) AND close(T2, still-forming bar) < Latest swing high(T2)
Short: On chart bars, Latest bullish FVG lower boundary exists AND close < Latest bullish FVG lower boundary AND close[previous-close lookback] > Latest bullish FVG lower boundary
Short: EMA(close, longer EMA lookback) > EMA(close, shorter EMA lookback)