Calculation: T1 EMA = EMA(close, lookback, T1 bars, latest available value sampled onto chart bars; last completed on historical bars and still forming on realtime bars)
Calculation: T2 EMA = EMA(close, lookback, T2 bars, latest available value sampled onto chart bars; last completed on historical bars and still forming on realtime bars)
Calculation: T3 EMA = EMA(close, lookback, T3 bars, latest available value sampled onto chart bars; last completed on historical bars and still forming on realtime bars)
Calculation: FLOW compression zone = highest(high, FLOW lookback) - lowest(low, FLOW lookback) < SMA(high - low, FLOW lookback) * FLOW lookback * compression factor AND SMA(volume, FLOW lookback) * FLOW lookback > SMA(volume, volume-average lookback) * FLOW lookback * volume-concentration factor
Calculation: Active FLOW base ceiling = highest(high, FLOW lookback) on a FLOW compression-zone bar; otherwise retain the prior value, initially undefined
Calculation: Active FLOW base floor = lowest(low, FLOW lookback) on a FLOW compression-zone bar; otherwise retain the prior value, initially undefined
Calculation: Previous NY session range = previous NY session high - previous NY session low
Calculation: Previous NY session body-to-range ratio = abs(previous NY session close - previous NY session open) / previous NY session range when the range is positive; otherwise undefined
Calculation: Previous NY session direction = bullish when its close > its open, bearish when its close < its open, otherwise neutral
Calculation: Previous NY close position = (previous NY session close - previous NY session low) / previous NY session range when the range is positive; otherwise the midpoint
Calculation: Previous NY session base = previous NY session body-to-range ratio < PD FLOW compression factor AND previous NY session volume > SMA(volume, daily volume lookback, T4 bars, last completed bar, sampled onto chart bars) * PD FLOW volume-concentration factor; false when the range is nonpositive or the SMA is unavailable
Calculation: PD FLOW efficiency threshold = PD FLOW breakout factor / PD FLOW divisor parameter
Long: close > open
Short: close < open
Long: close > Session VWAP((high + low + close) / 3, volume, selected London or NY session)
Short: close < Session VWAP((high + low + close) / 3, volume, selected London or NY session)
Long: RSI(close, RSI lookback), rounded to display precision, > RSI display threshold
Short: RSI(close, RSI lookback), rounded to display precision, < RSI display threshold
Long: Stoch RSI %K(RSI lookback, normalization lookback, K smoothing, zero when RSI range is zero) > Stoch RSI %D(same inputs, D smoothing)
Short: Stoch RSI %K(RSI lookback, normalization lookback, K smoothing, zero when RSI range is zero) < Stoch RSI %D(same inputs, D smoothing)
Long: close > EMA(close, short EMA lookback)
Short: close < EMA(close, short EMA lookback)
Long: close > EMA(close, medium EMA lookback)
Short: close < EMA(close, medium EMA lookback)
Long: close > EMA(close, long EMA lookback)
Short: close < EMA(close, long EMA lookback)
Long: close > EMA(close, longest EMA lookback)
Short: close < EMA(close, longest EMA lookback)
Long: chart close > T1 EMA(short EMA lookback)
Short: chart close < T1 EMA(short EMA lookback)
Long: chart close > T1 EMA(medium EMA lookback)
Short: chart close < T1 EMA(medium EMA lookback)
Long: chart close > T1 EMA(long EMA lookback)
Short: chart close < T1 EMA(long EMA lookback)
Long: chart close > T1 EMA(longest EMA lookback)
Short: chart close < T1 EMA(longest EMA lookback)
Long: chart close > T2 EMA(short EMA lookback)
Short: chart close < T2 EMA(short EMA lookback)
Long: chart close > T2 EMA(medium EMA lookback)
Short: chart close < T2 EMA(medium EMA lookback)
Long: chart close > T2 EMA(long EMA lookback)
Short: chart close < T2 EMA(long EMA lookback)
Long: chart close > T2 EMA(longest EMA lookback)
Short: chart close < T2 EMA(longest EMA lookback)
Long: chart close > T3 EMA(short EMA lookback)
Short: chart close < T3 EMA(short EMA lookback)
Long: chart close > T3 EMA(medium EMA lookback)
Short: chart close < T3 EMA(medium EMA lookback)
Long: chart close > T3 EMA(long EMA lookback)
Short: chart close < T3 EMA(long EMA lookback)
Long: chart close > T3 EMA(longest EMA lookback)
Short: chart close < T3 EMA(longest EMA lookback)
Long: EMA(close, shortest EMA lookback) > EMA(close, medium-short EMA lookback)
Short: EMA(close, shortest EMA lookback) < EMA(close, medium-short EMA lookback)
Long: EMA(close, short EMA lookback) > EMA(close, medium-long EMA lookback)
Short: EMA(close, short EMA lookback) < EMA(close, medium-long EMA lookback)
Long: EMA(close, medium EMA lookback) > EMA(close, long EMA lookback)
Short: EMA(close, medium EMA lookback) < EMA(close, long EMA lookback)
Long: EMA(close, long EMA lookback) > EMA(close, longest EMA lookback)
Short: EMA(close, long EMA lookback) < EMA(close, longest EMA lookback)
Long: high > Active FLOW base ceiling AND close > Active FLOW base ceiling AND high - low > SMA(high - low, FLOW lookback) * FLOW breakout-efficiency factor AND close > open AND close > close[1]
Short: low < Active FLOW base floor AND close < Active FLOW base floor AND high - low > SMA(high - low, FLOW lookback) * FLOW breakout-efficiency factor AND close < open AND close < close[1]
Long: previous NY session direction is bullish AND previous NY session body-to-range ratio > PD FLOW efficiency threshold AND NOT Previous NY session base
Short: previous NY session direction is bearish AND previous NY session body-to-range ratio > PD FLOW efficiency threshold AND NOT Previous NY session base
Long: Previous NY close position > NY bias bull threshold
Short: Previous NY close position < NY bias bear threshold AND Previous NY close position <= NY bias bull threshold