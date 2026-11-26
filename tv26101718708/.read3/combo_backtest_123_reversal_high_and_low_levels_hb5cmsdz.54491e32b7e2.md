Calculation: fast stochastic = SMA(Stochastic %K(close, high, low, stochastic lookback), fast smoothing)
Calculation: slow stochastic = SMA(fast stochastic, slow smoothing)
Calculation: reversal state = 1 if close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > oscillator threshold; -1 if close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < oscillator threshold; otherwise its previous value, initially 0
Calculation: level state = 1 if close > low[level lookback] from T1; else -1 if close < high[level lookback] from T1; else its previous value, initially 0. T1 high and low are sampled on chart bars; offset 0 uses the forming T1 bar, offset 1 the last completed T1 bar, and larger offsets earlier completed bars.
Long: reverse-direction switch is off AND reversal state = 1 AND level state = 1 OR reverse-direction switch is on AND reversal state = -1 AND level state = -1
Short: reverse-direction switch is off AND reversal state = -1 AND level state = -1 OR reverse-direction switch is on AND reversal state = 1 AND level state = 1
Exit: long, NOT ((reversal state = 1 AND level state = 1) OR (reversal state = -1 AND level state = -1))
Exit: short, NOT ((reversal state = 1 AND level state = 1) OR (reversal state = -1 AND level state = -1))