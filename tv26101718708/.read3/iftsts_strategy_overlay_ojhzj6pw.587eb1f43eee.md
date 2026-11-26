Calculation: Renko close = close of the Renko bar built from open using either ATR with an ATR lookback parameter or Traditional with a brick percentage parameter, from the T1 bar still forming, sampled on chart bars
Calculation: Renko open = open of the same Renko bar
Calculation: Renko brick size = ABS(Renko close - Renko open)
Calculation: Smoothed stochastic K = SMA(Stochastic(close, high, low, stochastic lookback), K smoothing)
Calculation: Smoothed stochastic D = SMA(Smoothed stochastic K, D smoothing)
Long: Renko close crosses above Renko open OR (Renko close > Renko open AND Smoothed stochastic K[1] < Smoothed stochastic D[1] AND Smoothed stochastic K[1] < lower-level parameter AND Smoothed stochastic K > Smoothed stochastic D)
Short: Renko close crosses below Renko open OR (Renko close < Renko open AND Smoothed stochastic K[1] > Smoothed stochastic D[1] AND Smoothed stochastic K[1] > upper-level parameter AND Smoothed stochastic K < Smoothed stochastic D)
Exit: long, close < Renko open - Renko brick size / 2 AND Renko close > Renko open
Exit: short, close > Renko open + Renko brick size / 2 AND Renko close < Renko open