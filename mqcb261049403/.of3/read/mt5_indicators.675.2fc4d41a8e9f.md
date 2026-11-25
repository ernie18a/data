Calculation: Mean bar range(T) = arithmetic mean of abs(high - low) over the range lookback bars ending at each T bar, including the bar still forming
Calculation: Movement event(T) = exists k from zero through movement scan lookback minus one such that abs(close[k + close lag] - close[k]) >= Mean bar range(T) * movement multiple
Calculation: Adaptive Stochastic %K(T) = Stochastic %K(close, high, low, shorter lookback when Movement event(T) is true, otherwise longer lookback)
Long: Adaptive Stochastic %K(chart)[0] > upper baseline + chart risk offset AND the most recent prior Adaptive Stochastic %K(chart) value outside [lower baseline - chart risk offset, upper baseline + chart risk offset] is below the lower band
Short: Adaptive Stochastic %K(chart)[0] < lower baseline - chart risk offset AND the most recent prior Adaptive Stochastic %K(chart) value outside [lower baseline - chart risk offset, upper baseline + chart risk offset] is above the upper band
Long: on each T1 bar, including the bar still forming, Adaptive Stochastic %K(T1)[0] > upper baseline + T1 risk offset AND the most recent prior Adaptive Stochastic %K(T1) value outside [lower baseline - T1 risk offset, upper baseline + T1 risk offset] is below the lower band
Short: on each T1 bar, including the bar still forming, Adaptive Stochastic %K(T1)[0] < lower baseline - T1 risk offset AND the most recent prior Adaptive Stochastic %K(T1) value outside [lower baseline - T1 risk offset, upper baseline + T1 risk offset] is above the upper band
Calculation: T1 trend state = direction of the most recent T1 bar with a long or short signal, sampled on each chart bar using T1 bars through the bar still forming
Long: T1 trend state is bullish
Short: T1 trend state is bearish