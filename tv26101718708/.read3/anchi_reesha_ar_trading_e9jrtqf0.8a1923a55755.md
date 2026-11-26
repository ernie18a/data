Calculation: BullTrend = EMA(close, faster EMA lookback) > EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) > EMA(close, slower EMA lookback)
Calculation: BearTrend = EMA(close, faster EMA lookback) < EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) < EMA(close, slower EMA lookback)
Calculation: BullHiddenDivergence = low > low[divergence comparison lag] AND RSI(close, RSI lookback) < RSI(close, RSI lookback)[divergence comparison lag] AND RSI(close, RSI lookback) < hidden bull RSI ceiling
Calculation: BearHiddenDivergence = high < high[divergence comparison lag] AND RSI(close, RSI lookback) > RSI(close, RSI lookback)[divergence comparison lag] AND RSI(close, RSI lookback) > hidden bear RSI floor
Calculation: AboveVWAP = close > VWAP(hlc3)
Calculation: VolumeSpike = volume > SMA(volume, volume lookback) × volume spike multiplier
Calculation: StrongCandle = high > low AND abs(close - open) / (high - low) > body fraction parameter
Calculation: LongScore = count of true conditions among (BullTrend, RSI(close, RSI lookback) > RSI midpoint AND RSI(close, RSI lookback) < RSI overbought threshold, AboveVWAP, VolumeSpike, BullHiddenDivergence, StrongCandle)
Calculation: ShortScore = count of true conditions among (BearTrend, RSI(close, RSI lookback) < RSI midpoint AND RSI(close, RSI lookback) > RSI oversold threshold, close < VWAP(hlc3), VolumeSpike, BearHiddenDivergence, StrongCandle)
Long: BullTrend
Short: BearTrend
Long: RSI(close, RSI lookback) > RSI midpoint
Short: RSI(close, RSI lookback) <= RSI midpoint
Long: AboveVWAP
Short: close <= VWAP(hlc3)
Long: BullHiddenDivergence
Short: BearHiddenDivergence
Long: LongScore >= minimum confluence score
Short: ShortScore >= minimum confluence score
Long: LongScore >= minimum confluence score AND LongScore > LongScore on the previous chart bar AND (no previous long signal OR current chart-bar index - previous long-signal chart-bar index > signal cooldown)
Short: ShortScore >= minimum confluence score AND ShortScore > ShortScore on the previous chart bar AND (no previous short signal OR current chart-bar index - previous short-signal chart-bar index > signal cooldown)