Calculation: ATR = SMA(TR[1], lookback)
Calculation: TRAIL = if MFI(hlc3[1], lookback) >= mfiLevel then MAX(low[1] - multiplier * ATR, TRAIL[1]) else MIN(high[1] + multiplier * ATR, TRAIL[1])
Calculation: SHOCK = abs(close[1] - close[2]) > shockMultiplier * ATR[1]
Calculation: SHOCK_UP = SHOCK AND close[1] crosses above TRAIL[1]
Calculation: SHOCK_DN = SHOCK AND close[1] crosses below TRAIL[1]
Calculation: BUY_SIGNAL = (TRAIL[1] > TRAIL[3] AND TRAIL[2] <= TRAIL[4]) OR SHOCK_UP
Calculation: SELL_SIGNAL = (TRAIL[1] < TRAIL[3] AND TRAIL[2] >= TRAIL[4]) OR SHOCK_DN
Calculation: BUY_AGE = if BUY_SIGNAL[1] then 0 else BUY_AGE[1] + 1
Calculation: SELL_AGE = if SELL_SIGNAL[1] then 0 else SELL_AGE[1] + 1
Calculation: LONG_OK = BUY_SIGNAL AND BUY_AGE > SELL_AGE
Calculation: SHORT_OK = SELL_SIGNAL AND SELL_AGE > BUY_AGE
Calculation: DIRECTION = if SHOCK_UP then 1 else if SHOCK_DN then -1 else if TRAIL[1] > TRAIL[3] then 1 else if TRAIL[1] < TRAIL[3] then -1 else DIRECTION[1]
Long: LONG_OK
Long: LONG_OK AND NOT LONG_OK[1]
Long: DIRECTION == 1
Long: LONG_OK(T1, last completed bar) AND change(time(T1, bar still forming))[1] != 0
Long: DIRECTION(T1, last completed bar) == 1
Short: SHORT_OK
Short: SHORT_OK AND NOT SHORT_OK[1]
Short: DIRECTION == -1
Short: SHORT_OK(T1, last completed bar) AND change(time(T1, bar still forming))[1] != 0
Short: DIRECTION(T1, last completed bar) == -1
Exit: long, close[1] < TRAIL[1]
Exit: short, close[1] > TRAIL[1]