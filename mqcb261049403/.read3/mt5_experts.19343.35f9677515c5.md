Long: long entries enabled AND NRTR ATR Stop(ATR lookback, multiplier, T1, last completed bar) changes from downtrend to uptrend on chart bars AND (time filter disabled OR datetime is within the configured trading interval)
Short: short entries enabled AND NRTR ATR Stop(ATR lookback, multiplier, T1, last completed bar) changes from uptrend to downtrend on chart bars AND (time filter disabled OR datetime is within the configured trading interval)
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance
Exit: long, bearish NRTR ATR Stop reversal on chart bars using T1's last completed bar AND long exits enabled AND short entries disabled
Exit: short, bullish NRTR ATR Stop reversal on chart bars using T1's last completed bar AND short exits enabled AND long entries disabled
Exit: long, time filter enabled AND datetime is outside the configured trading interval
Exit: short, time filter enabled AND datetime is outside the configured trading interval