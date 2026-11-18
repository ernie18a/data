Calculation: T1 change = (source(T1, still-forming bar) - source(T1, last completed bar)) / source(T1, last completed bar), sampled on chart bars
Long: HMA(source, lookback) > HMA(source, lookback)[1]
Short: HMA(source, lookback) <= HMA(source, lookback)[1]
Long: HMA(source, lookback) crosses above HMA(source, lookback)[1]
Short: HMA(source, lookback) crosses below HMA(source, lookback)[1]
Long: flat AND HMA(source, lookback) > HMA(source, lookback)[1] AND source > HMA(source, lookback)[1] AND T1 change > decision threshold
Short: flat AND HMA(source, lookback) < HMA(source, lookback)[1] AND source < HMA(source, lookback)[1] AND T1 change < decision threshold
Exit: long, (HMA(source, lookback) < HMA(source, lookback)[1] AND source < HMA(source, lookback)[1] AND T1 change < decision threshold) OR unrealized profit < stop-loss parameter OR unrealized profit > target parameter
Exit: short, (HMA(source, lookback) > HMA(source, lookback)[1] AND source > HMA(source, lookback)[1] AND T1 change > decision threshold) OR unrealized profit < stop-loss parameter OR unrealized profit > target parameter