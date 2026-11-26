Calculation: start-of-day balance = current account balance - sum of nonzero deal profits dated today
Long: no long position is open AND HighestHigh(high, entry lookback, T1, last completed bar) + tick size - ask >= broker minimum stop level
Short: no short position is open AND bid - (LowestLow(low, entry lookback, T1, last completed bar) - tick size) >= broker minimum stop level
Exit: long, current position price < LowestLow(low, exit lookback, T1, last completed bar) OR current equity < start-of-day balance - daily loss limit
Exit: short, current position price > HighestHigh(high, exit lookback, T1, last completed bar) OR current equity < start-of-day balance - daily loss limit