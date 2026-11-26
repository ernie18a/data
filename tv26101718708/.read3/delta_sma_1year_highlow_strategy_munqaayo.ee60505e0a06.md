Calculation: volume imbalance = volume when close > open, negative volume when close < open, otherwise zero
Calculation: average volume imbalance = SMA(volume imbalance, averaging lookback)
Calculation: rolling low = Lowest(average volume imbalance, range lookback)
Calculation: rolling high = Highest(average volume imbalance, range lookback)
Long: average volume imbalance crosses above the long entry level AND it has been below rolling low multiplied by the long low multiplier since its most recent crossover above the long state reset level, with the reset taking precedence if both events occur on one bar
Short: average volume imbalance is below rolling high multiplied by the sell signal threshold AND it has crossed above rolling high multiplied by the sell arm multiplier since its most recent bar below rolling high multiplied by the sell signal threshold and the sell state reset multiplier, with the reset taking precedence if both events occur on one bar