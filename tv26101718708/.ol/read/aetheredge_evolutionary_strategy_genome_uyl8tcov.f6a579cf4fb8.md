Calculation: ATR = average true range over a configurable lookback
Calculation: Trend gene = clip((close − long-lookback SMA(close)) / ATR / scale, −1, 1)
Calculation: Momentum gene = clip((close − close from a shorter lookback ago) / ATR / scale, −1, 1)
Calculation: Mean-reversion gene = clip(−((close − shorter-lookback SMA(close)) / standard deviation of close over that lookback) / scale, −1, 1)
Calculation: Volatility gene = clip((ATR over a lookback / its longer-lookback SMA − 1) × (1 if close > prior close, otherwise −1), −1, 1)
Calculation: Volume gene = clip((volume / its lookback SMA − 1) × (1 if close > open, otherwise −1), −1, 1)
Calculation: Best-genome signal = tanh of the sum of each gene multiplied by its weight in the highest-fitness genome. Each genome has five weights. Update fitness as an EMA of its earlier signal multiplied by the subsequent normalized close change; periodically retain the highest-fitness genomes and fill the population using fitness-based tournament selection, per-gene crossover, and mutation.
Long: more than 200 bars are available AND bar is confirmed AND best-genome signal > 0.05 AND absolute best-genome signal ≥ signal gate
Short: more than 200 bars are available AND bar is confirmed AND best-genome signal < −0.05 AND absolute best-genome signal ≥ signal gate