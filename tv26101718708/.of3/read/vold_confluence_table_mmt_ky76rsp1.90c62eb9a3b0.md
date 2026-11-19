Calculation: VOLD close = VOLD source close from T1 sampled onto chart bars, using the still-forming T1 bar in real time and the last completed T1 bar historically
Calculation: ADD close = ADD source close on chart bars
Calculation: TICK close = TICK source close on chart bars
Calculation: VOLD SMA = SMA(VOLD close, lookback), calculated on chart bars
Calculation: Freight bull = VOLD close > VOLD SMA AND VOLD close > VOLD close[1] AND VOLD close > VOLD strong threshold
Calculation: Freight bear = VOLD close <= VOLD SMA AND VOLD close < VOLD close[1] AND VOLD close < -VOLD strong threshold
Calculation: Bull score = (VOLD close > 0 ? 1 : 0) + (VOLD close > VOLD strong threshold ? 1 : 0) + (ADD close > 0 ? 1 : 0) + (ADD close > ADD strong threshold ? 1 : 0) + (TICK close > 0 ? 1 : 0) + (TICK close > TICK warning threshold ? 1 : 0)
Calculation: Bear score = (VOLD close < 0 ? 1 : 0) + (VOLD close < -VOLD strong threshold ? 1 : 0) + (ADD close <= 0 ? 1 : 0) + (ADD close < -ADD strong threshold ? 1 : 0) + (TICK close <= 0 ? 1 : 0) + (TICK close < -TICK warning threshold ? 1 : 0)
Long: Bull score >= 5
Long: Bull score == 4 AND NOT Freight bear
Long: VOLD close > 0
Long: ADD close > 0 AND NOT Freight bear
Long: TICK close > 0 AND NOT Freight bear
Long: VOLD close > VOLD SMA AND NOT Freight bull
Long: VOLD close crosses above VOLD SMA
Long: ADD close > 0 AND VOLD close < 0
Short: Bear score >= 5
Short: Bear score == 4 AND NOT Freight bull
Short: VOLD close < 0
Short: ADD close <= 0 AND NOT Freight bull
Short: TICK close <= 0 AND NOT Freight bull
Short: VOLD close <= VOLD SMA AND NOT Freight bear
Short: VOLD close crosses below VOLD SMA
Short: ADD close <= 0 AND VOLD close > 0 AND NOT Freight bull
Exit: long, (ADD close > 0 AND VOLD close < 0) OR (ADD close <= 0 AND VOLD close > 0)
Exit: short, (ADD close > 0 AND VOLD close < 0) OR (ADD close <= 0 AND VOLD close > 0)