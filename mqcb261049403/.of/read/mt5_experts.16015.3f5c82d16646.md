Calculation: Adaptive line L = on the chart timeframe, or a configurable higher timeframe using its last completed bar or its still-forming bar, calculate a configurable moving average M of a configurable OHLC-derived price. Over the same lookback as M, calculate V as the mean of (price - current M)². Initialize L to M; thereafter let D = (previous L - M)² and L = previous L + k × (M - previous L), where k = 0 if D < V or D = 0, otherwise k = 1 - V / D.
Calculation: Change d = L - previous L; volatility S = population standard deviation of d over a separate lookback. Round d and each of the two configurable volatility multiples of S to the price precision plus two decimal places. The second multiple is larger than the first.
Long: d > first volatility multiple AND d <= second volatility multiple OR d > second volatility multiple
Long: L > previous L
Long: L > previous L AND previous L < L two bars ago
Short: d < -first volatility multiple AND d >= -second volatility multiple OR d < -second volatility multiple
Short: L < previous L
Short: L < previous L AND previous L > L two bars ago
Exit: long, d < -first volatility multiple AND d >= -second volatility multiple OR d < -second volatility multiple
Exit: long, L < previous L
Exit: short, d > first volatility multiple AND d <= second volatility multiple OR d > second volatility multiple
Exit: short, L > previous L
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance