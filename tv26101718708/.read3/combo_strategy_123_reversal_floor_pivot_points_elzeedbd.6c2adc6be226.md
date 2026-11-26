Calculation: fast stochastic = SMA(Stochastic(close, high, low, stochastic lookback), fast smoothing lookback)
Calculation: slow stochastic = SMA(fast stochastic, slow smoothing lookback)
Calculation: floor pivot point = (high(T1, last completed bar) + low(T1, last completed bar) + close(T1, last completed bar)) / 3, sampled on each chart bar
Calculation: stochastic signal state = 1 if close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > threshold; otherwise -1 if close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < threshold; otherwise previous stochastic signal state or 0
Calculation: pivot signal state = on each chart bar, 1 if close > 2 * floor pivot point - low(T1, last completed bar); otherwise -1 if close < 2 * floor pivot point - high(T1, last completed bar); otherwise previous pivot signal state or 0
Long: stochastic signal state = 1 AND pivot signal state = 1
Short: stochastic signal state = -1 AND pivot signal state = -1