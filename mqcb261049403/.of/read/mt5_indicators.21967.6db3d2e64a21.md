Calculation: Volume-weighted CCI = the selected moving average of CCI of the selected OHLC-derived price multiplied by volume; use the same smoothing method and parameters for volume-weighted CCI and smoothed volume.
Calculation: Direction = the sign of the latest nonzero bar-to-bar change in volume-weighted CCI; retain the previous direction when the value is unchanged.
Calculation: Higher-timeframe values = calculate volume-weighted CCI, smoothed volume, and direction on the higher timeframe; sample the still-forming higher-timeframe bar on its first chart bar and hold those values until the next higher-timeframe bar.
Long: Volume-weighted CCI > positive threshold × smoothed volume OR direction > 0.
Short: Volume-weighted CCI < negative threshold × smoothed volume OR direction < 0.
Long: Higher-timeframe volume-weighted CCI > positive threshold × higher-timeframe smoothed volume OR higher-timeframe direction > 0.
Short: Higher-timeframe volume-weighted CCI < negative threshold × higher-timeframe smoothed volume OR higher-timeframe direction < 0.