Calculation: SMI = 100 × double EMA(close − midpoint of the highest high and lowest low over the lookback, smoothing length) ÷ (double EMA(highest high − lowest low over the lookback, smoothing length) ÷ 2)
Calculation: SMI signal = EMA(SMI, same smoothing length)
Long: SMI > SMI signal AND previous SMI ≤ previous SMI signal AND SMI < 0 AND close > EMA(close, configured length) AND datetime is within the configured backtest period AND time of day is within the morning session
Exit: long, close < EMA(close, configured length) OR high ≥ entry price × (1 + configured profit target percentage)