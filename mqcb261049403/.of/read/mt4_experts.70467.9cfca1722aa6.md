Calculation: RSI = Relative Strength Index of close (standard RSI); RSI1 = RSI on the last completed bar, RSI2 = RSI on the completed bar immediately before it (the RSI may be computed on any timeframe, evaluated at completed bars only; the overbought level is higher than the oversold level)
Long: RSI1 >= oversold level AND RSI1 > RSI2 AND no long position is open
Short: RSI1 <= overbought level AND RSI1 < RSI2 AND no short position is open
Exit: short, RSI1 >= oversold level AND RSI1 > RSI2 (close the short and reverse to long)
Exit: long, RSI1 <= overbought level AND RSI1 < RSI2 (close the long and reverse to short)