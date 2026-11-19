Calculation: Bullish confluence score = (VOLD > 0 ? 1 : 0) + (VOLD > strong VOLD threshold ? 1 : 0) + (ADD > 0 ? 1 : 0) + (ADD > strong ADD threshold ? 1 : 0) + (TICK > 0 ? 1 : 0) + (TICK > TICK warning threshold ? 1 : 0)
Calculation: Bearish confluence score = (VOLD < 0 ? 1 : 0) + (VOLD < -strong VOLD threshold ? 1 : 0) + (ADD <= 0 ? 1 : 0) + (ADD < -strong ADD threshold ? 1 : 0) + (TICK <= 0 ? 1 : 0) + (TICK < -TICK warning threshold ? 1 : 0)
Long: bullish confluence score >= trend day score threshold
Long: bullish confluence score = high confidence score
Long: VOLD crosses above SMA(VOLD on T1, VOLD SMA length)
Long: VOLD > 0
Long: ADD > 0
Long: TICK > 0
Long: VOLD > SMA(VOLD on T1, VOLD SMA length)
Long: ADD > 0 AND VOLD < 0
Short: bearish confluence score >= trend day score threshold
Short: bearish confluence score = high confidence score
Short: VOLD crosses below SMA(VOLD on T1, VOLD SMA length)
Short: VOLD < 0
Short: ADD <= 0
Short: TICK <= 0
Short: VOLD <= SMA(VOLD on T1, VOLD SMA length)
Short: ADD <= 0 AND VOLD > 0