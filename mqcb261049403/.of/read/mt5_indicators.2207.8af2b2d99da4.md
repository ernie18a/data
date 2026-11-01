Calculation: Stochastic momentum = 100 times the three-stage smoothed value of selected OHLC-derived price minus the midpoint of the lookback high and low, divided by the three-stage smoothed half-range of that high and low; use the same smoothing method and corresponding stage lengths for numerator and denominator, and return zero when the denominator is zero.
Calculation: Signal line = a moving average of stochastic momentum using the same smoothing method and an independent signal-line length.
Calculation: Sampled higher-timeframe values = stochastic momentum, its signal line, and the preceding higher-timeframe bar's stochastic momentum, calculated using the higher-timeframe bar still forming at the first chart bar of that higher-timeframe bar and held until the next higher-timeframe bar begins.
Long: Stochastic momentum > signal line.
Short: Stochastic momentum < signal line.
Long: Stochastic momentum > 0 AND stochastic momentum != previous chart bar's stochastic momentum.
Short: Stochastic momentum < 0 AND stochastic momentum != previous chart bar's stochastic momentum.
Long: Sampled higher-timeframe stochastic momentum > sampled higher-timeframe signal line.
Short: Sampled higher-timeframe stochastic momentum < sampled higher-timeframe signal line.
Long: Sampled higher-timeframe stochastic momentum > 0 AND sampled higher-timeframe stochastic momentum != sampled preceding higher-timeframe bar's stochastic momentum.
Short: Sampled higher-timeframe stochastic momentum < 0 AND sampled higher-timeframe stochastic momentum != sampled preceding higher-timeframe bar's stochastic momentum.