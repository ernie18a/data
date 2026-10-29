Calculation: Coppock oscillator = a moving average of the sum of the price rate of change over a longer lookback and the price rate of change over a shorter lookback, using the configured applied price. Calculate on the configured indicator timeframe, which may be higher, equal to, or lower than the chart timeframe. Evaluate at the configured signal bar, which may be forming or completed; the two preceding bars are completed.
Long: Coppock[t-2] > Coppock[t-1] AND Coppock[t] > Coppock[t-1]
Short: Coppock[t-2] < Coppock[t-1] AND Coppock[t] < Coppock[t-1]
Exit: long, Coppock[t-2] < Coppock[t-1] AND Coppock[t] < Coppock[t-1]
Exit: short, Coppock[t-2] > Coppock[t-1] AND Coppock[t] > Coppock[t-1]