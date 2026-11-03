Calculation: Impulse = SMA of weighted price (high + low + 2 × close) / 4 minus the smoothed moving average of high when the SMA is above that average; SMA minus the smoothed moving average of low when the SMA is below that average; otherwise 0. All three averages use the same lookback.
Calculation: Cloud line = impulse when impulse is nonzero; otherwise the previous cloud line.
Calculation: Cloud signal = SMA of impulse over a shorter lookback when impulse is nonzero; otherwise the current cloud line.
Long: Impulse > 0 AND impulse != previous bar's impulse, OR cloud line > cloud signal.
Short: Impulse < 0 AND impulse != previous bar's impulse, OR cloud line < cloud signal.
Long: Higher-timeframe impulse > 0 AND higher-timeframe impulse != previous higher-timeframe bar's impulse, OR higher-timeframe cloud line > higher-timeframe cloud signal; use the higher-timeframe bar still forming.
Short: Higher-timeframe impulse < 0 AND higher-timeframe impulse != previous higher-timeframe bar's impulse, OR higher-timeframe cloud line < higher-timeframe cloud signal; use the higher-timeframe bar still forming.