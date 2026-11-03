Calculation: MACD = short-lookback simple moving average of close minus long-lookback simple moving average of close; the signal line is a simple moving average of MACD.
Calculation: Stochastic RSI K = smoothed stochastic of RSI; D = smoothed K.
Calculation: Average-down deviations = initial deviation, then each next deviation equals the previous deviation multiplied by a scale factor plus the initial deviation.
Long: No open position AND selected signal is (MFI <= threshold OR RSI <= threshold OR MACD crosses above its signal line OR Stochastic RSI K crosses above D)
Long: Long position AND open order count is below the maximum AND low <= first entry price × (1 − next average-down deviation)
Exit: Long, high >= position average entry price × (1 + take-profit percentage)
Exit: Long, stop loss enabled AND all permitted orders are filled AND low <= last order price × (1 − stop-loss percentage)