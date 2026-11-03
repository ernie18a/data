Calculation: Oscillator = stochastic of a selected RSI variant applied to a selected OHLC-derived price, optionally smoothed first by a simple, exponential, smoothed, or linear weighted moving average. For each bar, find the RSI minimum and maximum over the stochastic lookback; oscillator = 100 × sum(RSI − minimum) / sum(maximum − minimum) over the slowing lookback, or zero when the denominator is zero. Calculate on the chart timeframe or on the still-forming higher-timeframe bar.
Calculation: Levels = fixed upper and lower thresholds, or rolling oscillator minimum plus the corresponding upper and lower percentages of its rolling range, or corresponding rolling oscillator quantiles. The middle level is the mean of the upper and lower levels for fixed or rolling-range levels, and the quantile at the mean of their percentages for quantile levels.
Long: Oscillator > upper level, when using outer-level mode.
Short: Oscillator < lower level, when using outer-level mode.
Long: Oscillator > middle level, when using middle-level mode.
Short: Oscillator < middle level, when using middle-level mode.
Long: Oscillator > previous oscillator, when using slope mode.
Short: Oscillator < previous oscillator, when using slope mode.