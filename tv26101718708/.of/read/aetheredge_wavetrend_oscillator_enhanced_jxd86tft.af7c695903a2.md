Calculation: WaveTrend = EMA(channel index, average length), where baseline = EMA(source, channel length), deviation = EMA(abs(source - baseline), channel length), and channel index = (source - baseline) / (0.015 × deviation), or zero when deviation is zero; source is a selectable price series computed from the input bars.
Calculation: WaveTrend signal = SMA(WaveTrend, signal length).
Calculation: Overbought and oversold levels = selectable fixed levels, nearest-rank upper and lower percentiles of WaveTrend over a common lookback, or SMA(WaveTrend) plus and minus a selectable multiple of its standard deviation over that lookback.
Calculation: Divergence = compare the two most recent confirmed WaveTrend pivot highs or lows, using the high or low of the price bar at each corresponding oscillator pivot. A pivot is confirmed after selectable numbers of left and right bars; evaluate divergence on the confirmation bar. Require the distance between pivot bars to be within selectable minimum and maximum limits. An optional zone restriction requires at least one of the two pivot values to be at or beyond the applicable overbought or oversold level measured on the confirmation bar.
Calculation: Higher-timeframe WaveTrend and signal = the same WaveTrend and signal calculations on higher-timeframe bars. With lookahead off, historical bars use the last completed higher-timeframe bar; the realtime bar can use the bar still forming. With lookahead on, historical bars receive the final higher-timeframe value from the start of that higher-timeframe bar; realtime bars use the bar still forming.
Long: WaveTrend crosses above its signal AND, in zone-cross mode, WaveTrend < oversold level AND, when higher-timeframe agreement is required and enabled, higher-timeframe WaveTrend > its signal.
Short: WaveTrend crosses below its signal AND, in zone-cross mode, WaveTrend > overbought level AND, when higher-timeframe agreement is required and enabled, higher-timeframe WaveTrend < its signal.
Long: A confirmed low-pivot divergence has newer price low < previous price low AND newer WaveTrend low > previous WaveTrend low.
Long: A confirmed low-pivot divergence has newer price low > previous price low AND newer WaveTrend low < previous WaveTrend low.
Short: A confirmed high-pivot divergence has newer price high > previous price high AND newer WaveTrend high < previous WaveTrend high.
Short: A confirmed high-pivot divergence has newer price high < previous price high AND newer WaveTrend high > previous WaveTrend high.
Long: WaveTrend > its signal.
Short: WaveTrend <= its signal.
Long: Higher-timeframe WaveTrend > its signal.
Short: Higher-timeframe WaveTrend <= its signal.
Long: WaveTrend - its signal > 0.
Short: WaveTrend - its signal <= 0.
Long: A regular bullish divergence occurred within a selectable recent lookback including the current bar.
Short: A regular bearish divergence occurred within a selectable recent lookback including the current bar AND no regular bullish divergence occurred within that lookback.