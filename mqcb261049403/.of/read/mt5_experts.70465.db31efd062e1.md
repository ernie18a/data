Calculation: RSI_fast = RSI of close on the lower timeframe of the two RSIs, with the shorter lookback of the two; use last completed bar (cur) and the completed bar before it (prev)
Calculation: RSI_slow = RSI of close on the higher timeframe of the two RSIs, with the longer lookback of the two; use last completed bar (cur) and the completed bar before it (prev)
Long: no long position is open AND RSI_fast.cur >= oversold_level AND RSI_fast.cur > RSI_fast.prev AND RSI_slow.cur >= oversold_level AND RSI_slow.cur > RSI_slow.prev (oversold_level is below overbought_level)
Short: no short position is open AND RSI_fast.cur <= overbought_level AND RSI_fast.cur < RSI_fast.prev AND RSI_slow.cur <= overbought_level AND RSI_slow.cur < RSI_slow.prev
Exit: short, the Long condition's RSI comparisons are true (close the short and open long)
Exit: long, the Short condition's RSI comparisons are true (close the long and open short)