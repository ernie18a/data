Calculation: Moving VWAP = rolling volume-weighted mean of the selected price source; if volume is unavailable and fallback is enabled, use the rolling simple mean. Calculate on the chart timeframe or selected timeframe; when that timeframe is higher than the chart, use its still-forming bar with no lookahead.
Calculation: Standard deviation = square root of max(rolling volume-weighted mean of source squared minus Moving VWAP squared, 0); if volume is unavailable, use the rolling sample standard deviation of the source.
Calculation: Oscillator = (source − Moving VWAP) / standard deviation in Z-score mode, otherwise source − Moving VWAP.
Calculation: Band 2 threshold = configured band level × standard deviation in Distance mode, otherwise the configured band level.
Long: Oscillator crosses above zero OR oscillator crosses above the positive Band 2 threshold.
Short: Oscillator crosses below zero OR oscillator crosses below the negative Band 2 threshold.