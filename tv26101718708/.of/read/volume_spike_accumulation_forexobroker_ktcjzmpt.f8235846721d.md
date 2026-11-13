Calculation: volume spike = volume >= multiple * SMA(volume, n)
Calculation: close position = (close - low) / (high - low), 0.5 if high == low
Calculation: accumulation bar = volume spike AND close position >= threshold (threshold > 0.5)
Calculation: distribution bar = volume spike AND close position <= 1 - threshold
Calculation: bias = persistent state, set to long on an accumulation bar and to short on a distribution bar, otherwise unchanged from the previous bar, so it holds until the opposite classified bar; updated on the current bar before the conditions below are evaluated
Calculation: reclaim EMA = EMA(close, n)
Long: (bias is long AND close crosses above reclaim EMA) OR accumulation bar; AND not already long AND bars since the last entry signal >= cooldown; evaluated on the closed bar
Short: (bias is short AND close crosses below reclaim EMA) OR distribution bar; AND not already short AND bars since the last entry signal >= cooldown; evaluated on the closed bar
Exit: long, the Short condition is met (reverse to short)
Exit: short, the Long condition is met (reverse to long)