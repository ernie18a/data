Calculation: Trend score = +0.5 when the shorter EMA is above the medium EMA, otherwise −0.5, plus +0.5 when the medium EMA is above the longer EMA, otherwise −0.5
Calculation: Momentum score = clamp(0.7 × (RSI − 50) / 25 + 0.3 × MACD histogram / ATR, −1, 1)
Calculation: Higher-timeframe score = +1 when the higher-timeframe close is above its EMA, otherwise −1; use the higher-timeframe bar returned with lookahead off, including its developing value when it is still forming
Calculation: Volume-flow score = clamp(EMA(sign(close − open) × volume) / average volume, −1, 1); use a shorter EMA lookback than the average-volume lookback
Calculation: Mean-reversion score = clamp(−(close − VWAP) / (2 × ATR), −1, 1)
Calculation: Bias = clamp(short EMA of the weighted average of trend, momentum, higher-timeframe, volume-flow, and mean-reversion scores, −1, 1); weights are user-set and normalized by their sum
Long: Bias > 0 AND absolute bias ≥ neutral dead-zone threshold AND ADX ≥ range threshold
Short: Bias < 0 AND absolute bias ≥ neutral dead-zone threshold AND ADX ≥ range threshold