Calculation: JMA approximation = Let beta = a(length - 1)/(a(length - 1) + b), alpha = beta squared; recursively compute e0 = (1 - alpha) source + alpha previous e0, e1 = (source - e0)(1 - beta) + beta previous e1, e2 = (e0 + phase multiplier × e1 - previous JMA)(1 - alpha) squared + alpha squared × previous e2, and JMA = previous JMA + e2.
Calculation: Moving averages = Each of the four independently selects JMA approximation, ALMA, KAMA, FRAMA, MAMA, or FAMA and a length; MAMA and FAMA ignore length. The entry fast length is shorter than the entry slow length, and the exit fast length is shorter than the exit slow length. Chart averages use a selected price source; higher-timeframe entry averages use close and the corresponding chart entry average types and lengths. Higher-timeframe values use the last completed higher-timeframe bar on historical bars and the still-forming higher-timeframe bar in real time.
Long: Entry fast moving average > entry slow moving average.
Short: Entry fast moving average <= entry slow moving average.
Long: Entry fast moving average >= entry slow moving average.
Short: Entry fast moving average < entry slow moving average.
Long: Higher-timeframe entry fast moving average > higher-timeframe entry slow moving average.
Short: Higher-timeframe entry fast moving average <= higher-timeframe entry slow moving average.
Long: Entry fast moving average crosses above entry slow moving average AND higher-timeframe entry fast moving average > higher-timeframe entry slow moving average; the higher-timeframe condition is optional.
Short: Entry fast moving average crosses below entry slow moving average AND higher-timeframe entry fast moving average <= higher-timeframe entry slow moving average; the higher-timeframe condition is optional.
Long: Entry fast moving average crosses above exit fast moving average OR entry fast moving average crosses above exit slow moving average OR entry slow moving average crosses above exit fast moving average.
Short: Entry fast moving average crosses below exit fast moving average OR entry fast moving average crosses below exit slow moving average OR entry slow moving average crosses below exit fast moving average.
Exit: long, exit fast moving average crosses below exit slow moving average.
Exit: short, exit fast moving average crosses above exit slow moving average.