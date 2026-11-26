Calculation: chart upper level = mean of the highest highs in the chart lookback number of T1 intervals; use the latest completed intervals when the chart period selector chooses completed intervals, otherwise use the T1 interval still forming and the preceding completed intervals; evaluate on chart bars
Calculation: chart lower level = mean of the lowest lows in the chart lookback number of T1 intervals; use the latest completed intervals when the chart period selector chooses completed intervals, otherwise use the T1 interval still forming and the preceding completed intervals; evaluate on chart bars
Calculation: chart trend state = bullish when chart close > chart upper level, bearish when chart close < chart lower level, otherwise retain the prior chart bar's state
Long: chart trend state is bullish
Long: chart trend state changes from not bullish to bullish
Short: chart trend state is bearish
Short: chart trend state changes from not bearish to bearish
Calculation: higher-timeframe upper level = mean of the highest highs in the higher-timeframe lookback number of T2 intervals aggregated from T1 bars; use the latest completed intervals when the higher-timeframe period selector chooses completed intervals, otherwise use the T2 interval still forming and the preceding completed intervals; calculate on T1 bars
Calculation: higher-timeframe lower level = mean of the lowest lows in the higher-timeframe lookback number of T2 intervals aggregated from T1 bars; use the latest completed intervals when the higher-timeframe period selector chooses completed intervals, otherwise use the T2 interval still forming and the preceding completed intervals; calculate on T1 bars
Calculation: higher-timeframe trend state = bullish when T1 close > higher-timeframe upper level, bearish when T1 close < higher-timeframe lower level, otherwise retain the prior T1 bar's state; chart bars use the value from their corresponding T1 bar, including the T1 bar still forming
Long: higher-timeframe trend state is bullish
Long: higher-timeframe trend state changes from not bullish to bullish
Short: higher-timeframe trend state is bearish
Short: higher-timeframe trend state changes from not bearish to bearish