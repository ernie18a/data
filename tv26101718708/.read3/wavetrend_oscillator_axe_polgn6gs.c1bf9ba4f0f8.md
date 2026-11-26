Calculation: WaveTrend signal(T) = Ehlers Super Smoother(EMA((log(source) − EMA(log(source), channel length)) / EMA(abs(log(source) − EMA(log(source), channel length)), channel length), average length), signal smoothing); on chart bars source is the selected source, and on T1 and T2 bars source is close. Calculate T1 and T2 values on their own bars and sample the current, possibly forming, bar onto chart bars with lookahead off.
Calculation: Bottom turn(T) = SMA(WaveTrend signal(T), MA period) < overbought threshold AND WaveTrend signal(T) crosses above SMA(WaveTrend signal(T), MA period) AND Sum(WaveTrend signal(T), turn/divergence lookback)[1] < Sum(SMA(WaveTrend signal(T), MA period), turn/divergence lookback)[1]; evaluate on T bars, sampling current, possibly forming T1 and T2 values onto chart bars.
Calculation: Top turn(T) = SMA(WaveTrend signal(T), MA period) > oversold threshold AND WaveTrend signal(T) crosses below SMA(WaveTrend signal(T), MA period) AND Sum(WaveTrend signal(T), turn/divergence lookback)[1] > Sum(SMA(WaveTrend signal(T), MA period), turn/divergence lookback)[1]; evaluate on T bars, sampling current, possibly forming T1 and T2 values onto chart bars.
Long: Bottom turn(chart bars)
Short: Top turn(chart bars)
Calculation: Regular bullish divergence(T) = Bottom turn(T) AND a prior bottom turn exists AND current SMA(WaveTrend signal(T), MA period) > its value at the prior bottom turn AND current Lowest(low, turn/divergence lookback) < its value at the prior bottom turn; evaluate on T bars, sampling current, possibly forming T1 and T2 values onto chart bars.
Calculation: Regular bearish divergence(T) = Top turn(T) AND a prior top turn exists AND current SMA(WaveTrend signal(T), MA period) < its value at the prior top turn AND current Highest(high, turn/divergence lookback) > its value at the prior top turn; evaluate on T bars, sampling current, possibly forming T1 and T2 values onto chart bars.
Calculation: Hidden bullish divergence = Bottom turn(chart bars) AND a prior bottom turn exists AND current SMA(WaveTrend signal, MA period) < its value at the prior bottom turn AND current Lowest(low, turn/divergence lookback) > its value at the prior bottom turn
Calculation: Hidden bearish divergence = Top turn(chart bars) AND a prior top turn exists AND current SMA(WaveTrend signal, MA period) > its value at the prior top turn AND current Highest(high, turn/divergence lookback) < its value at the prior top turn
Long: Regular bullish divergence(chart bars) OR hidden bullish divergence
Short: Regular bearish divergence(chart bars) OR hidden bearish divergence
Calculation: Latest regular-divergence direction(T) = bullish when Regular bullish divergence(T) occurs, bearish when Regular bearish divergence(T) occurs, otherwise the prior direction; initially neutral. Evaluate on T bars and sample current, possibly forming T1 and T2 values onto chart bars.
Long: Latest regular-divergence direction(chart bars) is bullish
Short: Latest regular-divergence direction(chart bars) is bearish
Long: Latest regular-divergence direction(T1) is bullish
Short: Latest regular-divergence direction(T1) is bearish
Long: Latest regular-divergence direction(T2) is bullish
Short: Latest regular-divergence direction(T2) is bearish
Long: WaveTrend signal > SMA(WaveTrend signal, MA period)
Short: WaveTrend signal <= SMA(WaveTrend signal, MA period)
Long: WaveTrend signal(T1) > SMA(WaveTrend signal(T1), MA period)
Short: WaveTrend signal(T1) <= SMA(WaveTrend signal(T1), MA period)
Long: WaveTrend signal(T2) > SMA(WaveTrend signal(T2), MA period)
Short: WaveTrend signal(T2) <= SMA(WaveTrend signal(T2), MA period)
Calculation: Last-at-event(value, event) = value when event occurs, otherwise its previous value; initialize to value.
Calculation: Cumulative rise(x, start, gate) = x − x[1] when start AND x > x[1] AND prior cumulative rise = 0 AND gate; otherwise prior cumulative rise + x − x[1] when x >= x[1] AND gate; otherwise 0.
Calculation: Cumulative fall(x, start, gate) = x[1] − x when start AND x < x[1] AND prior cumulative fall = 0 AND gate; otherwise prior cumulative fall + x[1] − x when x <= x[1] AND gate; otherwise 0.
Calculation: Bottom step = Last-at-event(SMA(WaveTrend signal, MA period), Bottom turn(chart bars))
Calculation: Top step = Last-at-event(SMA(WaveTrend signal, MA period), Top turn(chart bars))
Calculation: Price-bottom step = Last-at-event(Lowest(log(source), turn/divergence lookback), Bottom turn(chart bars))
Calculation: Price-top step = Last-at-event(Highest(log(source), turn/divergence lookback), Top turn(chart bars))
Calculation: Hidden bullish trend ratio = sqrt(Cumulative fall(Bottom step, true, true) × Cumulative rise(Price-bottom step, true, true)) / (1 + sqrt(Cumulative rise(Top step, true, true) × Cumulative fall(Price-top step, true, true)))
Calculation: Hidden bearish trend ratio = sqrt(Cumulative rise(Top step, true, true) × Cumulative fall(Price-top step, true, true)) / (1 + sqrt(Cumulative fall(Bottom step, true, true) × Cumulative rise(Price-bottom step, true, true)))
Calculation: Bullish trend strength = Cumulative rise(Bottom step, Bottom step[1] < oversold threshold OR Hidden bullish trend ratio[1] > Hidden bearish trend ratio[1], WaveTrend signal < overbought threshold) / (1 + Cumulative fall(Top step, Top step[1] > overbought threshold OR Hidden bearish trend ratio[1] > Hidden bullish trend ratio[1], WaveTrend signal > oversold threshold))
Calculation: Bearish trend strength = Cumulative fall(Top step, Top step[1] > overbought threshold OR Hidden bearish trend ratio[1] > Hidden bullish trend ratio[1], WaveTrend signal > oversold threshold) / (1 + Cumulative rise(Bottom step, Bottom step[1] < oversold threshold OR Hidden bullish trend ratio[1] > Hidden bearish trend ratio[1], WaveTrend signal < overbought threshold))
Long: Bullish trend strength > Bearish trend strength
Short: Bullish trend strength < Bearish trend strength
Long: WaveTrend signal > SMA(WaveTrend signal, MA period) AND WaveTrend signal(T1) > SMA(WaveTrend signal(T1), MA period) AND WaveTrend signal(T2) > SMA(WaveTrend signal(T2), MA period)
Short: WaveTrend signal <= SMA(WaveTrend signal, MA period) AND WaveTrend signal(T1) <= SMA(WaveTrend signal(T1), MA period) AND WaveTrend signal(T2) <= SMA(WaveTrend signal(T2), MA period)