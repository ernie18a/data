Calculation: SignalOpen = open of the last completed bar of the signal timeframe
Calculation: HighLevel = exponential moving average of length HighEmaLength of the highest SignalOpen over the last HighLookback bars
Calculation: LowLevel = exponential moving average of length LowEmaLength of the lowest SignalOpen over the last LowLookback bars
Calculation: HighShortAvg = simple moving average of HighLevel over the shorter period HighShortPeriod
Calculation: HighLongAvg = simple moving average of HighLevel over the longer period HighLongPeriod
Calculation: LowShortAvg = simple moving average of LowLevel over the shorter period LowShortPeriod
Calculation: LowLongAvg = simple moving average of LowLevel over the longer period LowLongPeriod
Long: HighShortAvg crosses under HighLongAvg
Short: LowShortAvg crosses over LowLongAvg