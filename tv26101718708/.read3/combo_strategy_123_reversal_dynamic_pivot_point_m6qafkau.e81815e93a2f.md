Calculation: Fast stochastic = SMA(Stochastic(close, high, low, stochastic lookback), fast smoothing lookback)
Calculation: Slow stochastic = SMA(Fast stochastic, slow smoothing lookback)
Calculation: Prior T1 pivot = (last completed T1 high + last completed T1 low + last completed T1 close) / 3, sampled on chart bars
Calculation: Reversal state = long if close[2] < close[1] AND close > close[1] AND Fast stochastic < Slow stochastic AND Fast stochastic > level; otherwise short if close[2] > close[1] AND close < close[1] AND Fast stochastic > Slow stochastic AND Fast stochastic < level; otherwise previous state, initially neutral
Calculation: Pivot state = long if chart-bar close > Prior T1 pivot + (Prior T1 pivot - last completed T1 low); otherwise short if chart-bar close < Prior T1 pivot - (last completed T1 high - Prior T1 pivot); otherwise previous state, initially neutral; evaluated on chart bars using last completed T1 values
Long: Reversal state = long AND Pivot state = long
Short: Reversal state = short AND Pivot state = short