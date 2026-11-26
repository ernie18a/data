Long: first bar with low < historical completed session or T1 box low
Short: first bar with high > historical completed session or T1 box high
Long: close > open(T1, bar still forming, sampled on chart bars)
Short: close <= open(T1, bar still forming, sampled on chart bars)
Long: close > open(T2, bar still forming, sampled on chart bars)
Short: close <= open(T2, bar still forming, sampled on chart bars)
Calculation: WaveTrend histogram = WaveTrend(hlc3, ESA lookback, TCI lookback) - SMA(WaveTrend(hlc3, ESA lookback, TCI lookback), signal lookback)
Long: WaveTrend histogram > 0
Short: WaveTrend histogram <= 0
Calculation: CVD since day boundary = cumulative sum(close > open ? volume : close < open ? -volume : 0), reset at each calendar day boundary
Long: CVD since day boundary > 0
Short: CVD since day boundary <= 0