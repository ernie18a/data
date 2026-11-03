Calculation: Volatility = absolute mean divided by standard deviation of log close-to-close returns over the volatility lookback on the analysis timeframe; include the current forming bar.
Calculation: Signal score = weighted sum of RSI momentum (RSI − 50), ADX strength (ADX − 20), fast SMA − slow SMA, volatility, and normalized random state; use only enabled modules. The fast SMA has a shorter lookback than the slow SMA. Adaptive weights are updated from recent closed-trade outcomes.
Calculation: Stop = entry price − ATR × stop multiplier for long positions, or entry price + ATR × stop multiplier for short positions; after trailing activation, use the adaptive ATR trailing stop when it tightens the stop.
Calculation: Take profit = entry price + ATR × max(take-profit multiplier, 0.5) for long positions, or entry price − ATR × max(take-profit multiplier, 0.5) for short positions.
Long: Signal score > decision threshold AND volatility >= volatility threshold
Short: Signal score < −decision threshold AND volatility >= volatility threshold
Exit: Long, low <= stop OR high >= take profit
Exit: Short, high >= stop OR low <= take profit