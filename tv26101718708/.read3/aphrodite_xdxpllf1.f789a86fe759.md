Calculation: U(s) = ((pi * previous-bar U(s), or initial-value parameter when missing) modulo (chart bar index + s)) modulo random-range parameter
Calculation: normal random value = SMA(average of open, high, low, and close, lookback) + standard deviation(average of open, high, low, and close, lookback) * sqrt(-2 * ln(U(seed))) * cos(2 * pi * U(-seed))
Calculation: composite flag(x) = 1 when x * price-scale parameter exceeds the minimum parameter and is divisible by any integer from the divisor lower-bound parameter through the divisor upper-bound parameter; otherwise 0
Long: abs(normal random value) <= high
Short: abs(normal random value) > high
Long: abs(normal random value) < low AND month(datetime) = month parameter AND day-of-month(datetime) = day parameter
Exit: long, composite flag(open) = 0 AND composite flag(high) = 0 AND composite flag(low) = 0 AND composite flag(close) = 0