Calculation: RSI = Relative Strength Index of close
Calculation: Fast RSI RMA = RMA of RSI with a shorter lookback than the slow RSI RMA
Calculation: Slow RSI RMA = RMA of RSI with a longer lookback than the fast RSI RMA
Calculation: Higher-timeframe fast and slow RSI RMAs = RMAs of RSI calculated on the last completed bar of a higher timeframe
Calculation: Initial risk distance = ATR of the chart timeframe on the last completed bar × stop multiplier
Calculation: Long stop = entry price − initial risk distance; short stop = entry price + initial risk distance
Calculation: Long target 3 = entry price + initial risk distance × target-3 multiple; short target 3 = entry price − initial risk distance × target-3 multiple
Long: Fast RSI RMA > slow RSI RMA OR (fast RSI RMA on the prior completed chart bar > slow RSI RMA and fast RSI RMA two bars back ≤ slow RSI RMA, with higher-timeframe fast RSI RMA > slow RSI RMA when the higher-timeframe filter is enabled, and ADX on the prior completed chart bar ≥ its threshold when the ADX filter is enabled)
Short: Fast RSI RMA < slow RSI RMA OR (fast RSI RMA on the prior completed chart bar < slow RSI RMA and fast RSI RMA two bars back ≥ slow RSI RMA, with higher-timeframe fast RSI RMA < slow RSI RMA when the higher-timeframe filter is enabled, and ADX on the prior completed chart bar ≥ its threshold when the ADX filter is enabled)
Exit: Long, low ≤ long stop OR high ≥ long target 3
Exit: Short, high ≥ short stop OR low ≤ short target 3