Calculation: SSL state = 1 when close > 200-bar SMA of high; -1 when close < 200-bar SMA of low; otherwise retain the prior state
Calculation: HAMA open = EMA of (prior bar open + prior bar close) / 2
Calculation: HAMA high = EMA of max(high, close)
Calculation: MA line = EMA(close, lookback)
Long: SSL state = 1 AND prior SSL state = -1 AND HAMA open > prior HAMA open AND MA line < (high + low) / 2 AND HAMA high < (high + low) / 2 AND no open position
Exit: long, high >= entry price * (1 + take-profit percentage / 100)
Exit: long, close < MA line AND (stop percentage disabled OR low <= entry price * (1 - stop-loss percentage / 100))