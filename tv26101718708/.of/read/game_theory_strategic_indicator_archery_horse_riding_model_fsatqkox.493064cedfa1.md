Calculation: Volume probability = clamp((current volume / simple moving average of volume over the strategy lookback − 1) × 0.5 + 0.5, 0, 1)
Calculation: Volatility = max(ATR over the strategy lookback / close × 100, 0.0001)
Calculation: Expected buyer utility = volume probability × (RSI over the strategy lookback − 50) / volatility + (1 − volume probability) × (50 − RSI over the strategy lookback) / volatility
Calculation: Expected seller utility = 0
Calculation: Bullish frequency = EMA over the strategy lookback of 1 when close > previous close, otherwise 0
Calculation: Replicator value = bullish frequency × (RSI over the strategy lookback / 100 − [bullish frequency × RSI over the strategy lookback / 100 + (1 − bullish frequency) × (1 − RSI over the strategy lookback / 100)])
Calculation: Minimax value = sum of positive returns divided by sum of absolute nonpositive returns over the minimax lookback, where each return is (previous close − current close) / current close; use 2 when the denominator is 0
Calculation: Equilibrium score = 1 − abs(expected buyer utility − expected seller utility) / max(abs(expected buyer utility), abs(expected seller utility)); use 0 when the denominator is 0
Calculation: Composite score = 0.4 × (expected buyer utility − expected seller utility) + 0.3 × replicator value + 0.3 × (minimax value − 1)
Long: Composite score > 0.5 AND expected buyer utility > expected seller utility AND equilibrium score ≤ configured equilibrium threshold
Short: Composite score < −0.5 AND expected buyer utility < expected seller utility AND equilibrium score ≤ configured equilibrium threshold