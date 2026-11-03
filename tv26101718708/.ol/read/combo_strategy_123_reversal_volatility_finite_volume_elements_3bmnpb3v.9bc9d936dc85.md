Calculation: Fast stochastic = the short-lookback SMA of 100 × (close − lowest low) / (highest high − lowest low), using the same lookback for highest high and lowest low
Calculation: Slow stochastic = the SMA of Fast stochastic over a second smoothing lookback
Calculation: Reversal direction = 1 when close[2] < close[1] AND close > close[1] AND Fast stochastic < Slow stochastic AND Fast stochastic > level; −1 when close[2] > close[1] AND close < close[1] AND Fast stochastic > Slow stochastic AND Fast stochastic < level; otherwise retain the previous value, initially 0
Calculation: Intrabar volatility = standard deviation of the short-lookback SMA of log(high) − log(low), using the same lookback for the SMA and standard deviation
Calculation: Interbar volatility = standard deviation of the short-lookback SMA of log(hlc3) − log(previous hlc3), using the same lookback for the SMA and standard deviation
Calculation: Adaptive cutoff = intrabar coefficient × Intrabar volatility + interbar coefficient × Interbar volatility
Calculation: Finite volume element = 100 × rolling sum of (volume × flow sign) / rolling sum of volume, using the same lookback for both sums; flow sign is 1 when close − hl2 + hlc3 − previous hlc3 > Adaptive cutoff × close, −1 when it is < −Adaptive cutoff × close, and 0 otherwise
Calculation: Finite volume direction = 1 when Finite volume element > its longer-lookback EMA; −1 when Finite volume element < its longer-lookback EMA; otherwise retain the previous value, initially 0
Long: Reversal direction = 1 AND Finite volume direction = 1
Short: Reversal direction = −1 AND Finite volume direction = −1