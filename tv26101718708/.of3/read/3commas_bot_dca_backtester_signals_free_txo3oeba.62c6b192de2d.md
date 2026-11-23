Calculation: MACD line = SMA(close, shorter lookback) - SMA(close, longer lookback)
Calculation: level deviation(k) = level deviation(k-1) * deviation multiplier + base deviation, level deviation(0) = 0
Long: number of open orders = 0 AND MACD line crosses above SMA(MACD line, signal lookback)
Long: number of open orders = 0 AND MFI(close, strategy length) <= threshold
Long: number of open orders = 0 AND RSI(close, strategy length) <= threshold
Long: number of open orders = 0 AND Stochastic RSI K(close, stochastic RSI length, stochastic lookback, K smoothing) crosses above SMA(Stochastic RSI K(close, stochastic RSI length, stochastic lookback, K smoothing), D smoothing)
Long: number of open orders >= 1 AND number of open orders < max orders AND low <= first order entry price * (1 - level deviation(number of open orders))
Exit: long, high >= average entry price * (1 + take profit)
Exit: long, number of open orders = max orders AND low <= last order entry price * (1 - stop loss)