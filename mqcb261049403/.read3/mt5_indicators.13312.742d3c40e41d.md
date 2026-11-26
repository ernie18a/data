Calculation: FilterDifference = FIR(applied-price parameter, shorter lookback and coefficient parameters) - FIR(applied-price parameter, longer lookback and coefficient parameters)
Long: FilterDifference > FilterDifference[1] on chart bars
Short: FilterDifference < FilterDifference[1] on chart bars
Long: FilterDifference > FilterDifference[1] on T1 bars, sampled on each chart bar from the T1 bar containing its time, including the still-forming bar
Short: FilterDifference < FilterDifference[1] on T1 bars, sampled on each chart bar from the T1 bar containing its time, including the still-forming bar