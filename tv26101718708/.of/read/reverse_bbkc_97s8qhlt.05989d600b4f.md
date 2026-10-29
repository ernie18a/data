Calculation: Bollinger upper/lower bands = SMA(close, lookback) ± multiplier × standard deviation(close, same lookback)
Calculation: Keltner upper/lower bands = EMA(close, lookback) ± multiplier × ATR(lookback)
Calculation: Squeeze = Bollinger upper < Keltner upper AND Bollinger lower > Keltner lower
Calculation: Initial stop = selected fixed-percentage stop from entry price or signal-bar extreme (short: high; long: low)
Calculation: Profit target = entry price ± initial risk × risk/reward ratio (short: subtract; long: add)
Calculation: Breakeven stop = entry price after price moves in favor by initial risk × breakeven trigger
Long: On a confirmed bar, close < Keltner lower AND (close < open if the candle-direction filter is enabled) AND (Squeeze is active OR the number of chart bars since it was last active ≤ the grace period) AND position is flat AND no entry is suppressed by the post-loss skip or trade locks
Short: On a confirmed bar, close > Keltner upper AND (close > open if the candle-direction filter is enabled) AND (Squeeze is active OR the number of chart bars since it was last active ≤ the grace period) AND position is flat AND no entry is suppressed by the post-loss skip or trade locks
Exit: Long, low ≤ active stop OR high ≥ profit target
Exit: Short, high ≥ active stop OR low ≤ profit target