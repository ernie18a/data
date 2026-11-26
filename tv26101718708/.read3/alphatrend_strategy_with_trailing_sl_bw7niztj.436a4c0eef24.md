Calculation: Long trailing stop = max(close * (1 - trailing-percentage parameter / 100), previous long trailing stop) while long; 0 otherwise
Calculation: Short trailing stop = min(close * (1 + trailing-percentage parameter / 100), previous short trailing stop) while short; positive reset sentinel otherwise
Long: crossover(AlphaTrend(source, lookback parameter, multiplier parameter, threshold parameter, volume mode), the same AlphaTrend lagged by a lag parameter)
Short: crossunder(AlphaTrend(source, lookback parameter, multiplier parameter, threshold parameter, volume mode), the same AlphaTrend lagged by a lag parameter)
Exit: long, trailing stop enabled AND low <= previous long trailing stop
Exit: short, trailing stop enabled AND high >= previous short trailing stop