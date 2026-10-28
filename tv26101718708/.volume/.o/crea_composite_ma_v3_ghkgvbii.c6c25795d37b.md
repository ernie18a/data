Calculation: EMA bias score = 3-bar EMA of 50 × (close above short EMA + short EMA above long EMA), where each comparison is 1 if true, else 0
Calculation: ADX directional score = normalize(+DI − −DI, lookback)
Calculation: Volatility score = (100 − normalize(ATR / close × 100, lookback) + EMA bias score) / 2
Calculation: Delta score = normalize(close − open, lookback)
Calculation: Volume score = 50 + (clamp((volume z-score + 2) / 4 × 100, 0, 100) − 50) × direction, where volume z-score uses a simple moving average and standard deviation over the same lookback, and direction is +1 when close ≥ open, otherwise −1
Calculation: Momentum score = normalize(ROC(close, lookback), lookback)
Calculation: Normalize(value, lookback) = (value − rolling minimum) / (rolling maximum − rolling minimum) × 100; use 50 when the maximum equals the minimum
Calculation: Composite = 3-bar EMA of the weighted average of EMA bias, MFI, ADX directional, volatility, delta, volume, and momentum scores
Calculation: Bullish agreement = count of the seven component scores greater than 50; bearish agreement = 7 − bullish agreement
Calculation: Higher-timeframe composite = the same composite calculated from aggregated higher-timeframe OHLCV, using the last completed higher-timeframe bar
Long: Composite crosses above the signal line AND bullish agreement ≥ early-agreement threshold AND higher-timeframe composite ≥ bullish higher-timeframe threshold AND composite < bullish threshold
Long: Composite crosses above bullish threshold AND bullish agreement ≥ confirmed-agreement threshold AND higher-timeframe composite ≥ bullish higher-timeframe threshold
Short: Composite crosses below the signal line AND bearish agreement ≥ early-agreement threshold AND higher-timeframe composite ≤ bearish higher-timeframe threshold AND composite > bearish threshold
Short: Composite crosses below bearish threshold AND bearish agreement ≥ confirmed-agreement threshold AND higher-timeframe composite ≤ bearish higher-timeframe threshold