Calculation: opening-range high = maximum high of chart bars from regular-session start until opening-range duration elapses
Calculation: opening-range low = minimum low of chart bars from regular-session start until opening-range duration elapses
Calculation: confirmation close = confirmed chart close when chart timeframe is at least T1; otherwise the preceding chart-bar close sampled at each T1 boundary, which is the last completed T1 close
Calculation: above-range streak = consecutive confirmation closes above opening-range high, reset to zero by a close at or below it, counted at each confirmation boundary after the opening range completes
Calculation: below-range streak = consecutive confirmation closes below opening-range low, reset to zero by a close at or above it, counted at each confirmation boundary after the opening range completes
Calculation: trail EMA = EMA(confirmation close, trail lookback), updated at each confirmation boundary
Calculation: longer lookback = max(1, round(longer high interval / chart-bar duration))
Calculation: shorter lookback = max(1, round(shorter high interval / chart-bar duration))
Calculation: longer prior high = Highest(high, longer lookback)[1] on chart bars
Calculation: pause bars = max(1, round(pause duration / chart-bar duration))
Calculation: most recent prior high-producing bar = most recent earlier chart bar whose high exceeded either its shorter or longer prior rolling high
Long: opening range complete AND ORB mode is touch AND high > opening-range high AND no earlier long ORB alert this session
Long: opening range complete AND ORB mode is close AND above-range streak >= confirm-bars AND no earlier long ORB alert this session
Short: opening range complete AND ORB mode is touch AND low < opening-range low AND no earlier short ORB alert this session
Short: opening range complete AND ORB mode is close AND below-range streak >= confirm-bars AND no earlier short ORB alert this session
Exit: long, long ORB alert has fired AND trail EMA[1] exists AND confirmation close < trail EMA[1] AND no earlier long trail exit
Exit: short, short ORB alert has fired AND trail EMA[1] exists AND confirmation close > trail EMA[1] AND no earlier short trail exit
Long: high > longer prior high AND (no prior high-producing bar OR current chart-bar index - most recent prior high-producing bar index >= pause bars)
Long: high > Highest(high, shorter lookback)[1] AND high <= longer prior high AND (no prior high-producing bar OR current chart-bar index - most recent prior high-producing bar index >= pause bars)