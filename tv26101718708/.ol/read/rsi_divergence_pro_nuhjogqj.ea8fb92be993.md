Calculation: RSI = 100 − 100 / (1 + Wilder-smoothed average gain / Wilder-smoothed average loss) on close changes
Calculation: RSI pivot low = an RSI value lower than the values in the preceding and following lookback bars; confirm after the following lookback bars
Calculation: RSI pivot high = an RSI value higher than the values in the preceding and following lookback bars; confirm after the following lookback bars
Long: two consecutive confirmed RSI pivot lows are within the minimum and maximum pivot-distance limits AND the newer pivot’s price low is lower than the prior pivot’s price low AND its RSI is higher
Long: two consecutive confirmed RSI pivot lows are within the minimum and maximum pivot-distance limits AND the newer pivot’s price low is higher than the prior pivot’s price low AND its RSI is lower
Short: two consecutive confirmed RSI pivot highs are within the minimum and maximum pivot-distance limits AND the newer pivot’s price high is higher than the prior pivot’s price high AND its RSI is lower
Short: two consecutive confirmed RSI pivot highs are within the minimum and maximum pivot-distance limits AND the newer pivot’s price high is lower than the prior pivot’s price high AND its RSI is higher
Exit: long, low <= entry price − ATR at entry × stop multiple OR high >= entry price + ATR at entry × target multiple OR bars since entry >= horizon
Exit: short, high >= entry price + ATR at entry × stop multiple OR low <= entry price − ATR at entry × target multiple OR bars since entry >= horizon