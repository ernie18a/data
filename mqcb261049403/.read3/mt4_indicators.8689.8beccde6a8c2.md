Calculation: Bullish stochastic-cross low = minimum Low of the two adjacent chart bars spanning the most recent bullish Stochastic %K/%D crossover within the search window
Calculation: Bearish stochastic-cross high = maximum High of the two adjacent chart bars spanning the most recent bearish Stochastic %K/%D crossover within the search window
Calculation: Buy stop level = maximum of the previous chart bar Low and either stochastic-cross level crossed upward by Close
Calculation: Sell stop level = minimum of the previous chart bar High and either stochastic-cross level crossed downward by Close
Long: Close crosses above the bullish stochastic-cross low
Short: Close crosses below the bearish stochastic-cross high
Long: MACD main line(close, fast EMA lookback, slow EMA lookback, signal SMA lookback) > 0 AND buy stop level is defined AND the still-forming T1 close sampled on chart bars > buy stop level AND the still-forming T2 close sampled on chart bars > buy stop level
Short: MACD main line(close, fast EMA lookback, slow EMA lookback, signal SMA lookback) < 0 AND sell stop level is defined AND the still-forming T1 close sampled on chart bars < sell stop level AND the still-forming T2 close sampled on chart bars < sell stop level