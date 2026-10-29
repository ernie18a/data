Calculation: Composite score = trend points (2 if fast EMA > slow EMA and close > trend EMA, 1 if only one is true, otherwise 0) + one point each for: smoothed difference between the shorter-lookback and longer-lookback close rate of change exceeding its threshold; relative performance versus SPY exceeding its threshold; volume exceeding its moving average times a surge multiplier; bullish regime; RSI above its midpoint and below its overbought threshold; stochastic %K above %D and below its overbought threshold; MACD histogram positive and rising; close above VWAP; ADX exceeding its threshold
Calculation: Bullish regime = close above regime EMA; when strict regime is enabled, regime EMA must also be rising
Calculation: Recent bullish cross = fast EMA crossed above slow EMA within the configured lookback
Calculation: Recent bearish cross = fast EMA crossed below slow EMA within the configured lookback
Long: Composite score >= buy minimum AND fast EMA > slow EMA AND bullish regime AND recent bullish cross AND buy cooldown elapsed
Long: Composite score >= strong-buy threshold
Long: Smoothed difference between the shorter-lookback and longer-lookback close rate of change > its threshold
Long: Stochastic %K > %D AND %K below its overbought threshold
Long: MACD histogram > 0 AND MACD histogram > its prior-bar value
Long: Volume >= volume moving average * surge multiplier AND fast EMA > slow EMA
Exit: long, Composite score <= sell maximum AND fast EMA < slow EMA AND bearish regime AND recent bearish cross AND sell cooldown elapsed