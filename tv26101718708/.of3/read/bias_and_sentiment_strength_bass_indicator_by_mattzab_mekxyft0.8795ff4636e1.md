Calculation: Scaled MACD histogram = 2 * (EMA(close, shorter MACD lookback) - EMA(close, longer MACD lookback) - EMA(EMA(close, shorter MACD lookback) - EMA(close, longer MACD lookback), MACD signal lookback)) * MACD scaling parameter
Calculation: Scaled RSI histogram = ((RSI(close, RSI lookback) - 50) / 5) * RSI scaling parameter
Calculation: Stochastic histogram = 1.5 * (((SMA(Stochastic(close, high, low, stochastic lookback), stochastic smoothing lookback) - 50) / 10) - SMA((SMA(Stochastic(close, high, low, stochastic lookback), stochastic smoothing lookback) - 50) / 10, stochastic signal lookback)) * stochastic scaling parameter
Calculation: Scaled Awesome Oscillator = 0.6 * Awesome Oscillator((high + low) / 2, shorter AO lookback, longer AO lookback) * AO scaling parameter
Calculation: Alligator gap = (SMMA((high + low) / 2, shorter Alligator lookback) - SMMA((high + low) / 2, longer Alligator lookback)) * Alligator scaling parameter
Long: Scaled MACD histogram >= 0
Short: Scaled MACD histogram < 0
Long: Scaled RSI histogram > 0
Short: Scaled RSI histogram <= 0
Long: Stochastic histogram > 0
Short: Stochastic histogram <= 0
Long: Scaled Awesome Oscillator > 0
Short: Scaled Awesome Oscillator <= 0
Long: Alligator gap >= 0
Short: Alligator gap < 0