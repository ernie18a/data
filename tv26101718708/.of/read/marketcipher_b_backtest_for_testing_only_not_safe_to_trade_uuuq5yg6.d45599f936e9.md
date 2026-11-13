Calculation: WT1 = EMA(CI, average length), CI = (hlc3 - ESA) / (0.015 * D), ESA = EMA(hlc3, channel length), D = EMA(|hlc3 - ESA|, channel length)
Calculation: WT2 = SMA(WT1, short length)
Calculation: Pivot(X) = 5-bar fractal on series X. Pivot bar c is the bar 2 bars before the current bar. Top pivot if X[c] > X on the 2 bars before c and the 2 bars after c. Bottom pivot if X[c] < X on those same 4 bars. Previous pivot = the most recent earlier pivot of the same type.
Calculation: K = SMA(100*(R - lowest(R, n)) / (highest(R, n) - lowest(R, n)), short smoothing), R = RSI(ln(close))
Calculation: BearReg(X) = top pivot of X AND high[c] > high at previous top pivot AND X[c] < X at previous top pivot
Calculation: BearHid(X) = top pivot of X AND high[c] < high at previous top pivot AND X[c] > X at previous top pivot
Calculation: BullReg(X) = bottom pivot of X AND low[c] < low at previous bottom pivot AND X[c] > X at previous bottom pivot
Calculation: BullHid(X) = bottom pivot of X AND low[c] > low at previous bottom pivot AND X[c] < X at previous bottom pivot
Calculation: for X = WT1 or WT2 in BullReg, 'X at previous bottom pivot' is X at the confirmation bar of that previous pivot (2 bars after its pivot bar), not at the pivot bar. All other pivot comparisons use X at the pivot bar.
Calculation: RSI = RSI(close)
Calculation: RefHi, RefHiRSI = on each bar, if RSI is the highest RSI over a recent lookback window including the current bar, set (RefHi, RefHiRSI) = (close, RSI); otherwise carry the previous values (initialised to close, RSI on the first bar). Then RefHi = max(RefHi, close) and RefHiRSI = max(RefHiRSI, RSI).
Calculation: RefLo, RefLoRSI = same as RefHi/RefHiRSI, using the lowest RSI in the window and min() in place of max()
Calculation: RSIBear = RefHi[1] > RefHi[2] AND RSI[1] < RefHiRSI AND RSI <= RSI[1] AND RSI[1] >= overbought threshold
Calculation: RSIBull = RefLo[1] < RefLo[2] AND RSI[1] > RefLoRSI AND RSI >= RSI[1] AND RSI[1] <= oversold threshold
Calculation: RSIBearHid = RefHi[1] < RefHi[2] AND RSI[1] < RefHiRSI
Calculation: RSIBullHid = RefLo[1] > RefLo[2] AND RSI[1] > RefLoRSI
Long: WT1 crosses above WT2 OR BullReg(K) OR BullHid(K) OR (BullReg(WT1) AND WT1 >= WT2) OR (BullReg(WT2) AND WT1 >= WT2) OR RSIBull OR RSIBullHid
Short: WT2 crosses above WT1 OR BearReg(K) OR BearHid(K) OR (BearReg(WT1) AND WT2 >= WT1) OR (BearReg(WT2) AND WT2 >= WT1) OR RSIBear OR RSIBearHid
Exit: long, WT2 crosses above WT1
Exit: short, WT1 crosses above WT2