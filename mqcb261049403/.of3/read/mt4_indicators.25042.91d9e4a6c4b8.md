Calculation: price deviation = close(T1, forming bar) - Bollinger middle band(close, Bollinger lookback, T1, forming bar), evaluated on chart bars using T1 data
Calculation: power imbalance = -(Bears Power(power lookback, close, T1, forming bar) + Bulls Power(power lookback, close, T1, forming bar)), evaluated on chart bars using T1 data
Calculation: signal magnitude = abs(price deviation) + abs(power imbalance); [1] denotes the last completed T1 bar
Long: price deviation > 0 AND power imbalance < 0 AND signal magnitude > signal magnitude[1] + change fraction * signal magnitude[1]
Short: price deviation < 0 AND power imbalance > 0 AND signal magnitude > signal magnitude[1] + change fraction * signal magnitude[1]
Exit: long, price deviation > 0 AND power imbalance < 0 AND signal magnitude < signal magnitude[1] - change fraction * signal magnitude[1]
Exit: short, price deviation < 0 AND power imbalance > 0 AND signal magnitude < signal magnitude[1] - change fraction * signal magnitude[1]