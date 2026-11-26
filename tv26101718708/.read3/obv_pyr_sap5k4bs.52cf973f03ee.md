Calculation: Centered OBV = OBV(close, volume) - SMA(OBV(close, volume), lookback)
Long: EMA(close, fast lookback) > EMA(close, slow lookback) AND Centered OBV crosses above 0; fast lookback is shorter than slow lookback
Exit: long, for each long entry, high >= entry price + close × profit target percentage / 100 OR low <= entry price - close × loss target percentage / 100