Calculation: Smoothed stochastic = EMA of 100 × (close − lowest low) / (highest high − lowest low), using the same lookback for both extrema and including the current bar; seed the EMA at 50.
Calculation: DSS = EMA of 100 × (smoothed stochastic − its rolling minimum) / (its rolling maximum − its rolling minimum), using the same lookback as the smoothed stochastic and including the current bar; use the same EMA period and seed at 50.
Long: Chart-timeframe DSS > chart-timeframe smoothed stochastic.
Short: Chart-timeframe DSS < chart-timeframe smoothed stochastic.
Long: DSS on the forming higher-timeframe bar > smoothed stochastic on the same bar.
Short: DSS on the forming higher-timeframe bar < smoothed stochastic on the same bar.