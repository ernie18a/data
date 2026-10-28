Calculation: Smoothed stochastic %K = SMA(100 × (close − lowest low over lookback) / (highest high over lookback − lowest low over lookback), smoothing period)
Calculation: Stochastic %D = SMA(smoothed stochastic %K, the same smoothing period)
Calculation: Long ATR stop = close − ATR × multiplier
Calculation: Short ATR stop = close + ATR × multiplier
Long: %K crosses above %D AND %K < oversold threshold AND fast EMA > slow SMA
Short: %K crosses below %D AND %K > overbought threshold AND fast EMA < slow SMA
Exit: long, %K crosses below %D AND %K > overbought-close threshold OR open < long ATR stop
Exit: short, %K crosses above %D AND %K < oversold-close threshold OR open > short ATR stop