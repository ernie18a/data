Calculation: Core line = VWMA(2 × VWMA(hl2 × volume, short lookback) / VWMA(volume, short lookback) − VWMA(hl2 × volume, medium lookback) / VWMA(volume, medium lookback), long lookback), where short < medium < long
Calculation: Long-term average = recursively smoothed close with a long lookback, initialized with the simple moving average over that lookback
Calculation: Signal state = latest direction whose entry condition was met; carry forward when neither condition is met
Long: Core line ≤ close − ATR(long lookback) × multiplier AND close > long-term average AND prior signal state ≠ long
Short: Core line ≥ close + ATR(long lookback) × multiplier AND close < long-term average AND prior signal state ≠ short