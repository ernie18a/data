Calculation: MA position state(T) = 1 if the close of the still-forming T bar is above MA(applied price, lookback, method, T, still-forming bar), -1 if below, and 0 if equal; evaluated on chart bars using T values
Calculation: MA trend state(chart) = direction of the most recent chart-bar close crossover above or below MA(applied price, lookback, method), or 0 if no crossover has occurred
Calculation: Advisor score = MA trend state(chart) + MA position state(T1) + MA position state(T2) + MA position state(T3)
Long: close crosses above MA(applied price, lookback, method)
Short: close crosses below MA(applied price, lookback, method)
Long: MA trend state(chart) = 1
Short: MA trend state(chart) != 1
Long: MA position state(T1) = 1
Short: MA position state(T1) != 1
Long: MA position state(T2) = 1
Short: MA position state(T2) != 1
Long: MA position state(T3) = 1
Short: MA position state(T3) != 1
Long: Advisor score >= 2
Short: Advisor score <= -2