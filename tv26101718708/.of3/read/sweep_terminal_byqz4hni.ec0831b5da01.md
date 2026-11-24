Calculation: FVG midpoint = average(upper FVG bound, lower FVG bound)
Long: close >= open of the current, still-forming T1 bar, sampled on chart bars
Short: close < open of the current, still-forming T1 bar, sampled on chart bars
Long: close >= open of the current, still-forming T2 bar, sampled on chart bars
Short: close < open of the current, still-forming T2 bar, sampled on chart bars
Long: close >= VWAP(hlc3)
Short: close < VWAP(hlc3)
Long: RSI(close, RSI lookback) >= RSI threshold
Short: RSI(close, RSI lookback) < RSI threshold
Long: DI+(DI lookback, smoothing) > DI-(DI lookback, smoothing)
Short: DI-(DI lookback, smoothing) > DI+(DI lookback, smoothing)
Long: low > high[gap separation lookback] AND low - high[gap separation lookback] >= ATR(ATR lookback) * gap-size threshold
Short: low[gap separation lookback] > high AND low[gap separation lookback] - high >= ATR(ATR lookback) * gap-size threshold
Long: Breakers mode AND a previously formed bearish FVG is mitigated by the selected source: max(open, close) > its upper bound for the body source, high > its upper bound for the wick source, or high > its midpoint for the midpoint source
Short: Breakers mode AND a previously formed bullish FVG is mitigated by the selected source: min(open, close) < its lower bound for the body source, low < its lower bound for the wick source, or low < its midpoint for the midpoint source
Long: on chart bars, after a chart bar closes below the previous completed low of T3, T4, or T5, a later chart bar closes at or above that same low
Short: on chart bars, after a chart bar closes above the previous completed high of T3, T4, or T5, a later chart bar closes at or below that same high
Long: on chart bars, close or high, according to the break-source parameter, exceeds the latest unbroken PivotHigh(high, pivot leg, pivot leg)
Short: on chart bars, close or low, according to the break-source parameter, falls below the latest unbroken PivotLow(low, pivot leg, pivot leg)
Long: the most recent confirmed market-structure break was upward
Short: the most recent confirmed market-structure break was downward
Long: the completed initial range within a T3, T4, or T5 period closes >= its open
Short: the completed initial range within a T3, T4, or T5 period closes < its open
Long: T1 is shorter than T2 AND close >= the open of the current, still-forming T1 bar AND close >= the open of the current, still-forming T2 bar AND a chart bar touches the previous completed low of T3, T4, or T5 AND, after that touch, the previous market-structure direction is downward and close or high, according to the break-source parameter, exceeds the latest unbroken PivotHigh(high, pivot leg, pivot leg) AND, after that break, a chart bar touches a chart-timeframe FVG midpoint