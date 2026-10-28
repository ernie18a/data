Calculation: SMI = 100 × EMA(EMA(close − (highest high + lowest low) / 2, smoothing length), same smoothing length) / (EMA(EMA(high − low, smoothing length), same smoothing length) / 2), where highest high and lowest low use the SMI lookback length
Calculation: SMI signal line = EMA(SMI, same smoothing length)
Calculation: EMA = exponential moving average of close
Long: SMI crosses above SMI signal line AND SMI < 0 AND close > EMA AND time is between 10:00 and 12:10
Exit: long, close < EMA OR high >= entry price × (1 + user-defined profit target percentage)