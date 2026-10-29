Calculation: N-bar log return = ln(current close / close N chart bars earlier)
Calculation: Regime threshold = volatility multiplier × standard deviation of one-bar log returns over a longer lookback × √N in adaptive mode; configured positive and negative percentage thresholds in fixed mode
Long: N-bar log return > positive regime threshold and the Bull regime persists for the configured minimum hold
Long: N-bar log return > 0 AND N-bar log return / positive regime threshold ≥ 0.70 AND N-bar log return is within the sideways regime
Short: N-bar log return < −negative regime threshold and the Bear regime persists for the configured minimum hold
Short: N-bar log return < 0 AND −N-bar log return / negative regime threshold ≥ 0.70 AND N-bar log return is within the sideways regime
Exit: Long, the prior completed chart bar's regime is not Bull
Exit: Short, the prior completed chart bar's regime is not Bear