Calculation: Safe ratio = numerator divided by denominator, or zero when the denominator is zero
Calculation: Efficiency ratio = Safe ratio(abs(close - close[efficiency lookback]), sum(abs(close - close[1]), efficiency lookback))
Calculation: Adaptive line = EMA(EMA(close, baseline lookback) + (KAMA(close, efficiency lookback, fast period, slow period) - EMA(close, baseline lookback)) × clamp(Efficiency ratio, to the unit interval), baseline smoothing)
Calculation: Session VWAP = session VWAP(hlc3), or EMA(hlc3, fallback lookback) when unavailable
Calculation: Volatility score = clamp(score center + score range × tanh(Safe ratio(ATR - SMA(ATR, volatility lookback), StDev(ATR, volatility lookback)) / score divisor), score floor, score ceiling)
Calculation: Trend strength = clamp(abs(adaptive line - adaptive line[1]) / max(ATR, minimum price increment) × slope weight + ADX(high, low, close, DMI lookback, DMI lookback) / ADX scale, strength floor, strength ceiling)
Calculation: Uptrend state = close > adaptive line AND adaptive line > adaptive line[1] AND EMA(close, short impulse lookback) > EMA(close, long impulse lookback)
Calculation: Downtrend state = close < adaptive line AND adaptive line < adaptive line[1] AND EMA(close, short impulse lookback) < EMA(close, long impulse lookback)
Calculation: Range state = ADX(high, low, close, DMI lookback, DMI lookback) < range ADX threshold AND trend strength < range strength threshold
Calculation: Up regime = Uptrend state AND NOT Range state
Calculation: Down regime = Downtrend state AND NOT Range state
Calculation: Anchor low = lowest(low, anchor lookback)
Calculation: Anchor span = max(highest(high, anchor lookback) - Anchor low, minimum price increment)
Calculation: Anchor midpoint = Anchor low + Anchor span × midpoint fraction
Calculation: Upper anchor cutoff = Anchor low + Anchor span × upper cutoff fraction
Calculation: Lower anchor cutoff = Anchor low + Anchor span × lower cutoff fraction
Calculation: Channel center = EMA(arithmetic mean of adaptive line and Session VWAP, max(channel smoothing floor, integer part of channel memory / channel smoothing divisor))
Calculation: Inner channel width = ATR × base channel ATR multiple × (base channel adjustment + clamp(Volatility score / inner score scale, inner clamp floor, inner clamp ceiling))
Calculation: Outer channel width = ATR × outer channel ATR multiple × (outer channel adjustment + clamp(Volatility score / outer score scale, outer clamp floor, outer clamp ceiling))
Calculation: Upper inner channel = Channel center + Inner channel width
Calculation: Lower inner channel = Channel center - Inner channel width
Calculation: Upper outer channel = Channel center + Outer channel width
Calculation: Lower outer channel = Channel center - Outer channel width
Calculation: Upper middle channel = Channel center + Inner channel width × middle channel fraction
Calculation: Lower middle channel = Channel center - Inner channel width × middle channel fraction
Long: Uptrend state
Short: Downtrend state
Long: Up regime
Short: Down regime
Long: close < Anchor midpoint
Short: close > Anchor midpoint
Long: close < Lower inner channel
Short: close > Upper inner channel
Long: ROC(close, momentum lookback) > zero
Short: ROC(close, momentum lookback) < zero
Long: close > Session VWAP
Short: close < Session VWAP
Long: confirmed bar AND Uptrend state AND low <= max(adaptive line, Lower middle channel) AND close > adaptive line AND close > open AND no bullish retest within the retest cooldown lookback
Short: confirmed bar AND Downtrend state AND high >= min(adaptive line, Upper middle channel) AND close < adaptive line AND close < open AND no bearish retest within the retest cooldown lookback
Long: confirmed bar AND low < Lower outer channel AND close > Lower inner channel
Short: confirmed bar AND high > Upper outer channel AND close < Upper inner channel
Long: confirmed bar AND close > Anchor midpoint AND close[1] <= Anchor midpoint AND close < Upper anchor cutoff
Short: confirmed bar AND close < Anchor midpoint AND close[1] >= Anchor midpoint AND close > Lower anchor cutoff
Long: confirmed bar AND Up regime AND NOT Up regime[1]
Short: confirmed bar AND Down regime AND NOT Down regime[1]