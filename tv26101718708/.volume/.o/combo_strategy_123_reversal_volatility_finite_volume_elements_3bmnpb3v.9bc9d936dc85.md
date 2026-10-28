Calculation: Fast stochastic = 100 × (close − lowest low over the lookback) / (highest high over the lookback − lowest low over the lookback)
Calculation: Smoothed stochastic = simple moving average of fast stochastic over the first smoothing lookback
Calculation: Slow stochastic = simple moving average of smoothed stochastic over a second smoothing lookback
Calculation: Adaptive cutoff = intrabar coefficient × standard deviation of the moving average of (ln(high) − ln(low)) + interbar coefficient × standard deviation of the moving average of (ln(typical price) − ln(previous typical price)); both moving averages and standard deviations use the same lookback, and typical price = (high + low + close) / 3
Calculation: Finite volume element (FVE) = 100 × sum(volume × direction factor over the lookback) / sum(volume over the lookback), where direction factor is +1 if (close − (high + low)/2 + typical price − previous typical price) exceeds adaptive cutoff × close, −1 if it is below −adaptive cutoff × close, and 0 otherwise
Calculation: FVE average = exponential moving average of FVE
Long: (close[2] < close[1] AND close > close[1] AND smoothed stochastic < slow stochastic AND smoothed stochastic > level) OR (FVE > FVE average)
Short: (close[2] > close[1] AND close < close[1] AND smoothed stochastic > slow stochastic AND smoothed stochastic < level) OR (FVE < FVE average)
Long: reversal signal is long AND FVE signal is long
Short: reversal signal is short AND FVE signal is short