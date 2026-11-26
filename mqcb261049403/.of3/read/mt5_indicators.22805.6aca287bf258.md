Calculation: FTMA change = FineTuningMACandle signal line − FineTuningMACandle signal line[1]
Calculation: FTMA change standard deviation = StandardDeviation(FTMA change, standard-deviation lookback)
Long: close > open
Short: close < open
Long: FTMA change > lower threshold multiplier × FTMA change standard deviation AND FTMA change <= upper threshold multiplier × FTMA change standard deviation
Short: FTMA change < −lower threshold multiplier × FTMA change standard deviation AND FTMA change >= −upper threshold multiplier × FTMA change standard deviation
Long: FTMA change > upper threshold multiplier × FTMA change standard deviation
Short: FTMA change < −upper threshold multiplier × FTMA change standard deviation
Calculation: T1 FTMA change = FineTuningMACandle signal line on the still-forming T1 bar − FineTuningMACandle signal line on the previous T1 bar
Calculation: T1 FTMA change standard deviation = StandardDeviation(T1 FTMA change, standard-deviation lookback) on T1 bars including the still-forming bar
Long: close of the still-forming T1 bar > open of the still-forming T1 bar, sampled onto chart bars
Short: close of the still-forming T1 bar < open of the still-forming T1 bar, sampled onto chart bars
Long: T1 FTMA change > lower threshold multiplier × T1 FTMA change standard deviation AND T1 FTMA change <= upper threshold multiplier × T1 FTMA change standard deviation, sampled onto chart bars
Short: T1 FTMA change < −lower threshold multiplier × T1 FTMA change standard deviation AND T1 FTMA change >= −upper threshold multiplier × T1 FTMA change standard deviation, sampled onto chart bars
Long: T1 FTMA change > upper threshold multiplier × T1 FTMA change standard deviation, sampled onto chart bars
Short: T1 FTMA change < −upper threshold multiplier × T1 FTMA change standard deviation, sampled onto chart bars