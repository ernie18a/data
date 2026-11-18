Long: crossover(low, EMA(close, lookback))
Long: crossover(close(T1, still-forming bar, sampled on chart bars), open(T1, still-forming bar, sampled on chart bars)) AND EMA(close, lookback) < open(T1, still-forming bar, sampled on chart bars) AND position is flat
Short: crossunder(high, EMA(close, lookback))
Short: crossunder(close(T1, still-forming bar, sampled on chart bars), open(T1, still-forming bar, sampled on chart bars)) AND EMA(close, lookback) > open(T1, still-forming bar, sampled on chart bars) AND position is flat
Exit: long, crossunder(close(T1, still-forming bar, sampled on chart bars), open(T1, still-forming bar, sampled on chart bars))
Exit: short, crossover(close(T1, still-forming bar, sampled on chart bars), open(T1, still-forming bar, sampled on chart bars))