Calculation: chart smoothed momentum = MA(MA(MA(applied price - applied price[momentum period], method 1, length 1, phase 1), method 2, length 2, phase 2), method 3, length 3, phase 3)
Calculation: chart signal = MA(chart smoothed momentum, method 4, length 4, phase 4)
Long: chart smoothed momentum > chart signal on chart bars
Short: chart smoothed momentum < chart signal on chart bars
Calculation: T1 smoothed momentum = MA(MA(MA(applied price(T1) - applied price(T1)[momentum period], method 1, length 1, phase 1), method 2, length 2, phase 2), method 3, length 3, phase 3), using T1 bars including the bar still forming
Calculation: T1 signal = MA(T1 smoothed momentum, method 4, length 4, phase 4), using T1 bars including the bar still forming
Long: T1 smoothed momentum > T1 signal on chart bars using T1's bar still forming
Short: T1 smoothed momentum < T1 signal on chart bars using T1's bar still forming