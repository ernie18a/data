Calculation: Reversal fast stochastic = SMA(Stochastic(close, high, low, reversal lookback), K smoothing)
Calculation: Reversal slow stochastic = SMA(Reversal fast stochastic, D smoothing)
Calculation: Volume-adjusted half-range acceleration = 0 when high = low or volume = 0; otherwise scale * ((half-range change - prior half-range change) / (volume / (high - low))), where half-range = (high - low) / 2 and half-range change = half-range - half-range[1]
Long: On T1 bars, close > close[1] AND close[1] > close[2] AND Slow Stochastic(close, high, low, lookback) < stochastic threshold
Short: On T1 bars, close < close[1] AND close[1] < close[2] AND Fast Stochastic(close, high, low, lookback) > stochastic threshold
Long: On chart bars, close[2] < close[1] AND close > close[1] AND Reversal fast stochastic < Reversal slow stochastic AND Reversal fast stochastic > reversal level
Short: On chart bars, close[2] > close[1] AND close < close[1] AND Reversal fast stochastic > Reversal slow stochastic AND Reversal fast stochastic < reversal level
Long: On chart bars, Volume-adjusted half-range acceleration > buy zone
Short: On chart bars, Volume-adjusted half-range acceleration < sell zone
Long: On chart bars, close[2] < close[1] AND close > close[1] AND Reversal fast stochastic < Reversal slow stochastic AND Reversal fast stochastic > reversal level AND Volume-adjusted half-range acceleration > buy zone
Short: On chart bars, close[2] > close[1] AND close < close[1] AND Reversal fast stochastic > Reversal slow stochastic AND Reversal fast stochastic < reversal level AND Volume-adjusted half-range acceleration < sell zone