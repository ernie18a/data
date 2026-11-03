Calculation: Break state = initially down; for each bar, compare its low and high with the lowest low and highest high of the preceding lookback bars, excluding the current bar. If the prior state is up and the current low is below that lowest low, set the state to down; otherwise retain the prior state. Then, if the resulting state is down and the current high is above that highest high, set the state to up.
Long: Chart-timeframe break state = up
Short: Chart-timeframe break state = down
Long: Higher-timeframe break state on the bar still forming = up
Short: Higher-timeframe break state on the bar still forming = down