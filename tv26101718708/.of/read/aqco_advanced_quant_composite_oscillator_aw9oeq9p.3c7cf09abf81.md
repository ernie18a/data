Calculation: Trend score = mean of the normalized momentum score, mean Katz fractal trend score across short, core, and long lookbacks, and rescaled-range Hurst score (2 × (Hurst − 0.5)); momentum is the 3-bar EMA of the MAD z-score of the band-pass filtered hlc3, clamped to [−1,1] after division by 3. The band-pass filter is a first-order high-pass of hlc3 followed by a first-order low-pass. Katz trend score = 1 − 2 × (Katz fractal dimension − 1). Hurst is the mean valid slope between adjacent scales of log(rescaled range / standard deviation) against log(scale), clamped to [0.05,0.95].
Calculation: Entropy score = 1 − 2 × normalized Shannon entropy of signed hlc3 returns, using a decaying histogram of return bins; normalize entropy by log(number of bins).
Calculation: Composite oscillator = EMA of the clamped weighted sum of trend score, entropy score, and optional lower-timeframe microtrend. Adapt the trend and entropy weights from Hurst and the percentile rank of core-lookback Katz dimension; normalize enabled weights to sum to 0.95. Optional microtrend uses lower-timeframe closes, sampled from the last completed lower-timeframe bar, and is the 3-bar SMA of lower-timeframe close changes divided by their standard deviation over a lookback half the short lookback, clamped to [−1,1].
Calculation: Confidence = clamp(1 − mean absolute difference between trend score and entropy score, and, when enabled, lower-timeframe microtrend, to [0,1]).
Long: Composite oscillator > 0.75 AND confidence > 0.60
Long: Composite oscillator crosses below −0.50 AND (absolute composite oscillator ≤ 0.15 OR Hurst < 0.52 OR normalized entropy > 0.85)
Long: Composite oscillator crosses above 0.50 AND NOT (absolute composite oscillator ≤ 0.15 OR Hurst < 0.52 OR normalized entropy > 0.85)
Long: Composite oscillator crosses above 0.15 AND NOT (absolute composite oscillator ≤ 0.15 OR Hurst < 0.52 OR normalized entropy > 0.85)
Short: Composite oscillator < −0.75 AND confidence > 0.60
Short: Composite oscillator crosses above 0.50 AND (absolute composite oscillator ≤ 0.15 OR Hurst < 0.52 OR normalized entropy > 0.85)
Short: Composite oscillator crosses below −0.50 AND NOT (absolute composite oscillator ≤ 0.15 OR Hurst < 0.52 OR normalized entropy > 0.85)
Short: Composite oscillator crosses below −0.15 AND NOT (absolute composite oscillator ≤ 0.15 OR Hurst < 0.52 OR normalized entropy > 0.85)
Exit: long, composite oscillator ≤ 0.15 OR confidence < 0.30
Exit: short, composite oscillator ≥ −0.15 OR confidence < 0.30