Calculation: Trend gene = clip((close − SMA(close, long lookback)) / ATR / 3, −1, 1)
Calculation: Momentum gene = clip((close − close from short lookback ago) / ATR / 3, −1, 1)
Calculation: Mean-reversion gene = clip(−((close − SMA(close, medium lookback)) / standard deviation of close over that lookback) / 2, −1, 1)
Calculation: Volatility gene = clip((ATR over short lookback / its longer-lookback SMA − 1) × (1 if close > prior close, otherwise −1), −1, 1)
Calculation: Volume gene = clip((volume / its SMA over a lookback − 1) × (1 if close > open, otherwise −1), −1, 1)
Calculation: Best-genome signal = tanh of the weighted sum of the five genes for the population member with highest running fitness; update fitness from prior signals by their product with the clipped realized forward move, and periodically evolve the population by elitism, fitness-based tournament selection, per-gene parent crossover, and mutation.
Long: after warmup AND on a confirmed bar AND best-genome signal is above the positive direction cutoff AND its absolute value is at least the signal gate
Short: after warmup AND on a confirmed bar AND best-genome signal is below the negative direction cutoff AND its absolute value is at least the signal gate