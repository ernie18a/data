Calculation: chart filtered price = Gaussian filter(chart applied price, chart lookback)
Calculation: T1 filtered price = Gaussian filter(T1 applied price, T1 lookback)
Long: chart filtered price[0] >= chart filtered price[1]
Short: chart filtered price[0] < chart filtered price[1]
Long: chart filtered price[1] - chart filtered price[0] < chart filtered price[2] - chart filtered price[1]
Short: chart filtered price[1] - chart filtered price[0] > chart filtered price[2] - chart filtered price[1]
Long: T1 filtered price[0] >= T1 filtered price[1] on T1 bars using the still-forming T1 bar, with values mapped to chart bars
Short: T1 filtered price[0] < T1 filtered price[1] on T1 bars using the still-forming T1 bar, with values mapped to chart bars
Long: T1 filtered price[1] - T1 filtered price[0] < T1 filtered price[2] - T1 filtered price[1] on T1 bars using the still-forming T1 bar, with values mapped to chart bars
Short: T1 filtered price[1] - T1 filtered price[0] > T1 filtered price[2] - T1 filtered price[1] on T1 bars using the still-forming T1 bar, with values mapped to chart bars