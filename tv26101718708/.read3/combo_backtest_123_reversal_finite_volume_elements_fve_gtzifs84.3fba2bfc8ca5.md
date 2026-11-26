Calculation: Fast stochastic = SMA(Stochastic(close, high, low, stochastic lookback), smoothing lookback)
Calculation: Slow stochastic = SMA(fast stochastic, slower smoothing lookback)
Calculation: Reversal signal = 1 when close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > stochastic threshold; -1 when close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < stochastic threshold; otherwise its prior value, initially 0
Calculation: Finite-volume-element value = its prior value (or 0 initially) + 100 × signed volume / (SMA(volume, normalization lookback) × normalization lookback), where signed volume is volume when flow > volume threshold factor × close / 100, -volume when flow < -volume threshold factor × close / 100, and 0 otherwise, and flow = close - (high + low)/2 + (high + low + close)/3 - ((high + low + close)/3)[1]
Calculation: Volume-flow signal = 1 when finite-volume-element value > its value one bar ago AND > its value two bars ago; -1 when it is < both values; otherwise its prior value, initially 0
Calculation: Combined signal = 1 when reversal signal = 1 AND volume-flow signal = 1; -1 when both signals = -1; otherwise 0
Calculation: Trade signal = combined signal when trade reversal is disabled, and -combined signal when enabled
Long: Trade signal = 1
Short: Trade signal = -1
Exit: long, Trade signal = 0
Exit: short, Trade signal = 0