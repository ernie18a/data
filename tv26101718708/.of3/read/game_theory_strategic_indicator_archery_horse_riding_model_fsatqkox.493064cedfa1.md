Calculation: Mixed-strategy probability = clamp(0.5 + 0.5 * ((SMA(volume, strategy lookback) > 0 ? volume / SMA(volume, strategy lookback) : 1) - 1), 0, 1)
Calculation: Safe volatility = ATR(high, low, close, strategy lookback) / close * 100 if positive, otherwise volatility floor
Calculation: Buyer utility = (2 * mixed-strategy probability - 1) * (RSI(close, strategy lookback) - 50) / safe volatility
Calculation: Bullish frequency = EMA(close > close[1] ? 1 : 0, strategy lookback)
Calculation: Replicator dynamics = bullish frequency * (1 - bullish frequency) * (2 * RSI(close, strategy lookback) / 100 - 1)
Calculation: Minimax = sum(max((close[i-1] - close[i]) / close[i], 0) for available i from 1 through minimax lookback) / sum(max((close[i] - close[i-1]) / close[i], 0) for available i from 1 through minimax lookback), or no-loss fallback if the denominator is 0
Calculation: Composite score = buyer utility * utility weight + replicator dynamics * replicator weight + (minimax - 1) * minimax weight
Long: composite score > long score threshold AND buyer utility > 0
Short: composite score < short score threshold AND buyer utility < 0