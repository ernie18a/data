Calculation: Timeframe RSI = RSI of close on each of five configured timeframes, ordered fastest to slowest. On a higher timeframe use the last completed bar; on a lower timeframe use the last completed intrabar within the chart bar. RSI lengths may differ by timeframe.
Calculation: Composite RSI = weighted average of the available timeframe RSIs, with equal greatest weights on the two middle-slow timeframes, equal smaller weights on the fastest and slowest timeframes, and an intermediate weight on the second-fastest timeframe; use the neutral RSI midpoint if none is available.
Calculation: Composite channel = EMA of the rolling highest and lowest composite RSI; its midpoint is the average of those two EMAs. The upper and lower exhaustion thresholds are the midpoint plus or minus a configurable multiple of the corresponding distance to the upper or lower EMA, clamped to the RSI range. The corresponding extreme thresholds use a larger multiple, or fixed upper and lower thresholds.
Calculation: RSI pivot = a high or low of an RSI series confirmed by the same configurable number of bars before and after the pivot. Compare consecutive pivots of the same kind, using price high at each RSI high pivot and price low at each RSI low pivot. For each timeframe RSI, calculate pivots and prices on that timeframe; for composite RSI, use chart bars.
Long: Any timeframe RSI or composite RSI <= its oversold buy threshold.
Short: Any timeframe RSI or composite RSI >= its overbought sell threshold.
Long: Any timeframe RSI or composite RSI >= its bullish-state lower threshold AND < its overbought sell threshold.
Short: Any timeframe RSI or composite RSI <= its bearish-state upper threshold AND > its oversold buy threshold.
Long: A newly confirmed RSI low pivot is higher than the preceding RSI low pivot AND its corresponding price low is lower than at the preceding pivot.
Short: A newly confirmed RSI high pivot is lower than the preceding RSI high pivot AND its corresponding price high is higher than at the preceding pivot.
Long: Fastest-timeframe RSI <= its moderate low threshold AND slowest-timeframe RSI >= its moderate high threshold.
Short: Fastest-timeframe RSI >= its moderate high threshold AND slowest-timeframe RSI <= its moderate low threshold.
Long: Composite RSI crosses below its lower exhaustion threshold OR crosses below its lower extreme threshold.
Short: Composite RSI crosses above its upper exhaustion threshold OR crosses above its upper extreme threshold.