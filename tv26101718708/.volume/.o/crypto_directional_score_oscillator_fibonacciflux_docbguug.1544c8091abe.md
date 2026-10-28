Calculation: Trend = clamp((shorter-lookback EMA(close) - longer-lookback EMA(close)) / (2 × ATR), -1, 1)
Calculation: Momentum = clamp(log(close / close[longer-than-one-bar lag]) / (rolling standard deviation of one-bar log returns × √momentum lookback), -2, 2) / 2
Calculation: Mean reversion = clamp((shorter-lookback EMA(close) - close) / (2 × ATR), -1, 1)
Calculation: Flow = clamp(clamp((2 × close - high - low) / max(high - low, minimum price increment), -1, 1) × min(volume / its rolling average, 2) / 2, -1, 1)
Calculation: Efficiency = clamp(abs(close - close[efficiency lookback]) / sum of absolute one-bar close changes over that lookback, 0, 1)
Calculation: Fixed Up score = logistic(1.6 × (Efficiency × (0.55 × Trend + 0.30 × Momentum) + (1 - Efficiency) × 0.65 × Mean reversion + 0.25 × Flow))
Calculation: Down score = 1 - Up score
Long: confirmed bar and Up score crosses upward through the signal threshold
Short: confirmed bar and Down score crosses upward through the signal threshold
