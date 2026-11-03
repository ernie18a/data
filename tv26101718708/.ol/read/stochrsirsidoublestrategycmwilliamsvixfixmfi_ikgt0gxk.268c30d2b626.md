Calculation: Price stochastic signal = SMA(Stochastic(close, high, low, Stoch lookback), K smoothing)
Calculation: Stoch RSI K = SMA(Stochastic(RSI(close, RSI lookback), Stoch lookback), K smoothing)
Calculation: Stoch RSI D = SMA(Stoch RSI K, D smoothing)
Long: Price stochastic signal crosses above Stoch RSI D AND Stoch RSI K is below its oversold threshold AND RSI(close) crosses above its oversold threshold
Short: Price stochastic signal crosses below Stoch RSI D AND Price stochastic signal is above its overbought threshold AND RSI(close) crosses below its overbought threshold