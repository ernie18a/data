Calculation: Confirmed pivot high = a bar's high is greater than the highs of the specified number of bars before and after it
Calculation: Confirmed pivot low = a bar's low is less than the lows of the specified number of bars before and after it
Calculation: Previous pivot high/low = the confirmed pivot high/low immediately before the most recent confirmed pivot high/low
Long: On a confirmed bar, close > most recent confirmed pivot high not previously broken AND (HTF RSI > 50 when the HTF filter is enabled; RSI uses the last completed bar of a higher timeframe)
Short: On a confirmed bar, close < most recent confirmed pivot low not previously broken AND (HTF RSI < 50 when the HTF filter is enabled; RSI uses the last completed bar of a higher timeframe)
Exit: Long, high >= the pivot high immediately preceding the broken pivot high OR (before the target is hit and when auto-invalidation is enabled, close < the most recent confirmed pivot low recorded at the breakout)
Exit: Short, low <= the pivot low immediately preceding the broken pivot low OR (before the target is hit and when auto-invalidation is enabled, close > the most recent confirmed pivot high recorded at the breakout)