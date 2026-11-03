Calculation: Upper level = round the average of the highest highs of N consecutive N-bar windows to a configurable price increment. The windows end at offsets S through S+N-1 from the current bar, where offset 0 is the current bar.
Calculation: Lower level = round the average of the lowest lows of M consecutive M-bar windows to a configurable price increment. The windows end at offsets T through T+M-1 from the current bar. M, T, and the rounding increment are independent of the upper-level parameters.
Long: Chart-timeframe close > upper level AND chart-timeframe close >= lower level
Short: Chart-timeframe close < lower level
Long: Forming higher-timeframe close > higher-timeframe upper level AND forming higher-timeframe close >= higher-timeframe lower level
Short: Forming higher-timeframe close < higher-timeframe lower level