Calculation: Mother bar = the first chart bar initially; retain it while each subsequent bar has high <= mother high AND low >= mother low; otherwise replace it with that subsequent bar. A non-inside bar is a bar that replaces the mother, including the first bar.
Calculation: Gap bars = the latest three consecutive non-inside bars A, B, C, oldest first, with P the non-inside bar before A. Bullish gap = C.low > A.high AND (C.low > B.high ? B.high : C.low) > (B.low > A.high ? B.low : A.high). Bearish gap = C.high < A.low AND (B.high < A.low ? B.high : A.low) > (C.high < B.low ? B.low : C.high).
Calculation: Order-block candidates = two initially false persistent flags, bullish and bearish, updated on each confirmed non-inside bar after gap bars are available. Before updating flags, a matching gap and candidate produce an order block unless B.high > A.high AND B.low < A.low; in either case clear both flags. If a block was produced, skip the flag update. Otherwise set the bullish flag if P exists AND (A.low < P.low OR B.low < A.low), and set the bearish flag if P exists AND (A.high > P.high OR B.high > A.high); leave other flags unchanged.
Calculation: WaveTrend = EMA of (HLC3 - EMA(HLC3, channel length)) / (0.015 * EMA(abs(HLC3 - EMA(HLC3, channel length)), channel length)), using a separately parameterized smoothing length. Calculate on each selected timeframe, which can be higher or lower than the chart timeframe; use either its last completed bar or its still-forming bar, according to the confirmation setting.
Long: Bullish gap = true.
Short: Bearish gap = true.
Long: Bullish gap = true AND bullish order-block candidate = true AND NOT (B.high > A.high AND B.low < A.low).
Short: Bearish gap = true AND bearish order-block candidate = true AND NOT (B.high > A.high AND B.low < A.low).
Long: At least one timeframe is enabled AND WaveTrend > 0 on every enabled timeframe.
Short: At least one timeframe is enabled AND WaveTrend < 0 on every enabled timeframe.
Long: WaveTrend on an enabled timeframe > positive strength threshold.
Short: WaveTrend on an enabled timeframe < negative strength threshold.