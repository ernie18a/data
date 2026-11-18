Calculation: T1 source series = source sampled from T1 with lookahead off and mapped onto chart bars; history offsets count chart bars, using the last completed T1 bar historically until its close and the forming T1 bar in realtime
Long: HMA(source, lookback) > HMA(source, lookback)[1] AND source > T1 source series AND T1 source series[1] > T1 source series[2] AND source > T1 source series[1]
Short: HMA(source, lookback) < HMA(source, lookback)[1] AND source < T1 source series AND T1 source series[1] < T1 source series[2] AND source < T1 source series[1]
Exit: long, open profit < stop-loss parameter OR open profit > target-profit parameter
Exit: short, open profit < stop-loss parameter OR open profit > target-profit parameter