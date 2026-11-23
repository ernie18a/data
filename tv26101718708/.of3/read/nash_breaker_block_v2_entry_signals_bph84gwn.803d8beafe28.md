Calculation: UpPrice(m) = high if m is intrabar, else close
Calculation: DownPrice(m) = low if m is intrabar, else close
Calculation: SwingHigh = latest PivotHigh(high, pivot length, pivot length), or none if an earlier chart bar since its confirmation had UpPrice(BOS break mode) above it
Calculation: SwingLow = latest PivotLow(low, pivot length, pivot length), or none if an earlier chart bar since its confirmation had DownPrice(BOS break mode) below it
Calculation: Gap, formed on a chart bar where a T2 bar completes, = bullish if low(T2, last completed bar) > high(T2, the T2 bar two bars before it), with top = low(T2, last completed bar) and bottom = high(T2, the T2 bar two bars before it); or bearish if high(T2, last completed bar) < low(T2, the T2 bar two bars before it), with top = low(T2, the T2 bar two bars before it) and bottom = high(T2, last completed bar)
Calculation: Fuel(side, level) = exists a Gap formed within the last max gap age chart bars, whose direction is side (long: bullish, short: bearish) unless the direction-match parameter is off, that no chart bar from its formation to the previous bar overlaps (high >= bottom and low <= top) unless the untouched-gap parameter is off, and that has top <= level and level - top <= max gap distance for long, or bottom >= level and bottom - level <= max gap distance for short
Calculation: CycleOpen(A) = open of the latest T3 bar starting at anchor time A (clock time in the timezone parameter; the bar may still be forming) that is not earlier than the latest T3 bar starting at the globex anchor time G
Calculation: OpenBreakUp(A) = UpPrice(open-break mode) > CycleOpen(A) AND close[1] <= CycleOpen(A)
Calculation: OpenBreakDown(A) = DownPrice(open-break mode) < CycleOpen(A) AND close[1] >= CycleOpen(A)
Long: UpPrice(BOS break mode) > SwingHigh AND Fuel(long, SwingHigh) AND (BOS EMA-side parameter off OR UpPrice(BOS break mode) > EMA(close, EMA period, T1, last completed bar))
Long: (OpenBreakUp(G) OR OpenBreakUp(M) OR OpenBreakUp(N)) AND (open-break EMA-side parameter off OR close > EMA(close, EMA period, T1, forming bar))
Long: CycleOpen(N) > CycleOpen(M) AND CycleOpen(M) > CycleOpen(G)
Long: close > EMA(close, EMA period, T1, forming bar)
Short: DownPrice(BOS break mode) < SwingLow AND Fuel(short, SwingLow) AND (BOS EMA-side parameter off OR DownPrice(BOS break mode) < EMA(close, EMA period, T1, last completed bar))
Short: (OpenBreakDown(G) OR OpenBreakDown(M) OR OpenBreakDown(N)) AND (open-break EMA-side parameter off OR close < EMA(close, EMA period, T1, forming bar))
Short: CycleOpen(N) <= CycleOpen(M) AND CycleOpen(M) <= CycleOpen(G)
Short: close < EMA(close, EMA period, T1, forming bar)