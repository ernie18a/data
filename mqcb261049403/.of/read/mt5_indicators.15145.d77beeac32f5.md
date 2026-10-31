Calculation: Zero-lag line = 2 × first moving average of a selected OHLC-derived price − second moving average of the first moving average; the two moving averages have independently selectable methods and parameters.
Calculation: Line change = zero-lag line − previous bar's zero-lag line.
Calculation: Filter threshold = rolling population standard deviation of line change, including the current bar, multiplied by a selectable coefficient; round both the threshold and line change to the same selectable price precision before comparing.
Calculation: Higher-timeframe values = the same calculations on the higher-timeframe bar still forming, sampled at the first chart bar of that higher-timeframe bar and carried forward until the next higher-timeframe bar begins.
Long: Current zero-lag line > previous zero-lag line.
Short: Current zero-lag line < previous zero-lag line.
Long: Rounded line change > filter threshold.
Short: Rounded line change < −filter threshold.
Long: Higher-timeframe zero-lag line > previous higher-timeframe zero-lag line.
Short: Higher-timeframe zero-lag line < previous higher-timeframe zero-lag line.
Long: Higher-timeframe rounded line change > higher-timeframe filter threshold.
Short: Higher-timeframe rounded line change < −higher-timeframe filter threshold.