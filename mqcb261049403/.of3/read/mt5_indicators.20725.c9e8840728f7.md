Calculation: Adaptive EMA = previous Adaptive EMA + [minimum weight + (maximum weight - minimum weight) × (1 - exp(-|selected price - previous Adaptive EMA / sensitivity divisor|^sensitivity exponent))] × (selected price - previous Adaptive EMA)
Calculation: Adaptive EMA change = current Adaptive EMA - previous-bar Adaptive EMA
Calculation: Adaptive EMA change standard deviation = StdDev(Adaptive EMA change, lookback)
Long: current Adaptive EMA > previous-bar Adaptive EMA
Short: current Adaptive EMA < previous-bar Adaptive EMA
Long: rounded Adaptive EMA change > lower multiplier × Adaptive EMA change standard deviation AND rounded Adaptive EMA change <= upper multiplier × Adaptive EMA change standard deviation
Long: rounded Adaptive EMA change > upper multiplier × Adaptive EMA change standard deviation
Short: rounded Adaptive EMA change >= -upper multiplier × Adaptive EMA change standard deviation AND rounded Adaptive EMA change < -lower multiplier × Adaptive EMA change standard deviation
Short: rounded Adaptive EMA change < -upper multiplier × Adaptive EMA change standard deviation