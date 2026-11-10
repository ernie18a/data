Calculation: Higher-timeframe gap bars = the last completed bar and the bar two higher-timeframe bars before it.
Calculation: Latest and previous pivot highs and lows = the two most recently confirmed pivot highs and lows on an intermediate higher timeframe, using configurable left and right pivot lookbacks; update them when the confirming bar completes.
Calculation: Stored bullish gap top = the most recent low of a completed higher-timeframe gap bar whose low exceeds the high two bars earlier, recorded while gap display is enabled; update it only when that low differs from the stored top.
Calculation: Stored bearish gap top = the most recent low two bars before a completed higher-timeframe gap bar whose high is below that earlier low, recorded while gap display is enabled; update it only when that earlier low differs from the stored top.
Long: Last completed higher-timeframe close > its EMA.
Short: Last completed higher-timeframe close < its EMA.
Long: Last completed higher-timeframe low > higher-timeframe high two bars earlier.
Short: Last completed higher-timeframe high < higher-timeframe low two bars earlier.
Long: Latest intermediate higher-timeframe pivot high > previous pivot high.
Long: Latest intermediate higher-timeframe pivot low > previous pivot low.
Short: Latest intermediate higher-timeframe pivot high < previous pivot high.
Short: Latest intermediate higher-timeframe pivot low < previous pivot low.
Short: Structure display enabled AND latest intermediate higher-timeframe pivot high exists AND (previous pivot high does not exist OR latest pivot high <= previous pivot high).
Short: Structure display enabled AND latest intermediate higher-timeframe pivot low exists AND (previous pivot low does not exist OR latest pivot low <= previous pivot low).
Long: Chart-timeframe shorter EMA > longer EMA.
Short: Chart-timeframe shorter EMA <= longer EMA.
Long: Last completed higher-timeframe low > higher-timeframe high two bars earlier AND stored bullish gap top exists AND close <= stored bullish gap top AND close >= higher-timeframe high two bars earlier.
Short: Last completed higher-timeframe high < higher-timeframe low two bars earlier AND stored bearish gap top exists AND close >= last completed higher-timeframe high AND close <= stored bearish gap top.
Long: Latest intermediate higher-timeframe pivot low exists AND close >= latest pivot low - close × proximity fraction AND close <= latest pivot low + close × proximity fraction.
Short: Latest intermediate higher-timeframe pivot high exists AND close >= latest pivot high - close × proximity fraction AND close <= latest pivot high + close × proximity fraction.
Long: Signal display enabled AND last completed higher-timeframe close > its EMA AND latest intermediate higher-timeframe pivot high > previous pivot high AND latest pivot low > previous pivot low AND ((last completed higher-timeframe low > higher-timeframe high two bars earlier AND stored bullish gap top exists AND close <= stored bullish gap top AND close >= higher-timeframe high two bars earlier) OR (close >= latest pivot low - close × proximity fraction AND close <= latest pivot low + close × proximity fraction)) AND chart-timeframe shorter EMA crosses above longer EMA.
Short: Signal display enabled AND last completed higher-timeframe close < its EMA AND latest intermediate higher-timeframe pivot high < previous pivot high AND latest pivot low < previous pivot low AND ((last completed higher-timeframe high < higher-timeframe low two bars earlier AND stored bearish gap top exists AND close >= last completed higher-timeframe high AND close <= stored bearish gap top) OR (close >= latest pivot high - close × proximity fraction AND close <= latest pivot high + close × proximity fraction)) AND chart-timeframe shorter EMA crosses below longer EMA.