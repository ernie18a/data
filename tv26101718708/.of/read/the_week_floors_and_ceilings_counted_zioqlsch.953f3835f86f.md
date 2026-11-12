Calculation: PriorWeekHigh = high of the last completed bar of a higher timeframe (weekly), held fixed for the whole current week
Calculation: PriorWeekLow = low of the last completed bar of the same higher timeframe (weekly), held fixed for the whole current week
Long: (high > PriorWeekHigh AND no earlier bar in the current week had high > PriorWeekHigh) OR (close > PriorWeekHigh AND previous bar close <= PriorWeekHigh)
Short: (low < PriorWeekLow AND no earlier bar in the current week had low < PriorWeekLow) OR (close < PriorWeekLow AND previous bar close >= PriorWeekLow)