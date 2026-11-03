Calculation: Trend score = +0.5 when the short-term EMA is above the medium-term EMA, otherwise −0.5, plus +0.5 when the medium-term EMA is above the long-term EMA, otherwise −0.5.
Calculation: Momentum score = clamp(0.7 × (RSI − 50) / 25 + 0.3 × MACD histogram / ATR, −1, 1).
Calculation: Higher-timeframe score = +1 when the higher-timeframe close is above its 50-period EMA, otherwise −1; use the last completed higher-timeframe bar.
Calculation: Volume-flow score = clamp(EMA of sign(close − open) × volume / average volume, −1, 1), using a shorter lookback for the EMA than for average volume.
Calculation: Mean-reversion score = clamp(−(close − VWAP) / (2 × ATR), −1, 1).
Calculation: Bias = clamp(short-term EMA of the weighted average of the trend, momentum, higher-timeframe, volume-flow, and mean-reversion scores, −1, 1).
Calculation: Sideways = absolute bias is below a threshold OR ADX is below a threshold.
Long: bias > 0 AND NOT sideways.
Short: bias < 0 AND NOT sideways.