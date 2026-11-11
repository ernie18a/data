Calculation: Volume probability = clamp(volume / SMA(volume, strategy lookback) / 2, 0, 1); use a volume ratio of 1 when the volume SMA is not positive.
Calculation: Safe volatility = ATR(strategy lookback) / close × 100 if positive, otherwise 0.0001.
Calculation: Buyer utility = (1 − volume probability) × (50 − RSI(close, strategy lookback)) / safe volatility; seller utility = 0.
Calculation: Equilibrium score = 1 − abs(buyer utility − seller utility) / max(abs(buyer utility), abs(seller utility)) when the denominator is positive, otherwise 0.
Calculation: Bullish frequency = EMA(close > previous close ? 1 : 0, strategy lookback); bullish fitness = RSI(close, strategy lookback) / 100; average fitness = bullish frequency × bullish fitness + (1 − bullish frequency) × (1 − bullish fitness); replicator = bullish frequency × (bullish fitness − average fitness).
Calculation: Win/loss ratio = sum of positive close-to-close fractional returns / sum of absolute nonpositive close-to-close fractional returns over the available bars within the win/loss lookback; use 2 when the loss sum is zero.
Calculation: Best response = 1 if buyer utility > seller utility, −1 if seller utility > buyer utility, otherwise 0; confidence = abs(buyer utility − seller utility).
Calculation: Composite score = 0.4 × best response × confidence + 0.3 × replicator + 0.3 × (win/loss ratio − 1).
Long: Composite score > 0.5 AND equilibrium score <= equilibrium threshold AND best response > 0.
Short: Composite score < −0.5 AND equilibrium score <= equilibrium threshold AND best response < 0.