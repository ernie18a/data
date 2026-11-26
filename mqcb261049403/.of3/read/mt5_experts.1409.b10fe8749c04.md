Calculation: Smoothed TTF = T3(Trend Trigger Factor(high, low, lookback), smoothing length, phase) calculated on T1 bars; n is the signal-bar offset (n=0 is forming; n>0 is completed)
Long: Smoothed TTF[n] > Smoothed TTF[n+1] AND Smoothed TTF[n+1] <= Smoothed TTF[n+2]
Long: Smoothed TTF[n] > upper level AND Smoothed TTF[n+1] <= upper level
Short: Smoothed TTF[n] < Smoothed TTF[n+1] AND Smoothed TTF[n+1] >= Smoothed TTF[n+2]
Short: Smoothed TTF[n] < lower level AND Smoothed TTF[n+1] >= lower level
Exit: Long, Smoothed TTF[n] < Smoothed TTF[n+1] AND Smoothed TTF[n+1] < Smoothed TTF[n+2]
Exit: Short, Smoothed TTF[n] > Smoothed TTF[n+1] AND Smoothed TTF[n+1] > Smoothed TTF[n+2]
Exit: Short, Smoothed TTF[n] > lower level AND (Smoothed TTF[n] <= upper level OR Smoothed TTF[n+1] > upper level)