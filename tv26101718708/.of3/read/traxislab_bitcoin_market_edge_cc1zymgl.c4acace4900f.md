Calculation: RiskATR = ATR(ATR lookback), or close × ATR fallback fraction when ATR is unavailable
Calculation: VAEMA(source, length) = recursive EMA using length when volatility adjustment is off, otherwise effective length max(minimum effective length, length / clamp(ATR(ATR lookback) / SMA(ATR, ATR-average lookback), volatility-factor floor, volatility-factor ceiling)); use a neutral volatility factor when the ATR average is unavailable or nonpositive; fast, mid, and slow lengths are ordered shortest to longest
Calculation: BullTrend = fast VAEMA > mid VAEMA AND mid VAEMA > slow VAEMA AND (RiskATR > 0 ? 100 × (fast VAEMA − fast VAEMA[slope lookback]) / RiskATR : 0) > trend-slope threshold
Calculation: BearTrend = fast VAEMA < mid VAEMA AND mid VAEMA < slow VAEMA AND (RiskATR > 0 ? 100 × (fast VAEMA − fast VAEMA[slope lookback]) / RiskATR : 0) < −trend-slope threshold
Calculation: BullOBV = EMA(OBV, OBV smoothing lookback) > EMA(EMA(OBV, OBV smoothing lookback), twice the OBV smoothing lookback) AND EMA(OBV, OBV smoothing lookback) > its value slope lookback bars ago
Calculation: BearOBV = EMA(OBV, OBV smoothing lookback) < EMA(EMA(OBV, OBV smoothing lookback), twice the OBV smoothing lookback) AND EMA(OBV, OBV smoothing lookback) < its value slope lookback bars ago
Calculation: BullBOS = current close > the last confirmed PivotHigh(high, pivot lookback, pivot lookback) AND prior close ≤ that pivot high
Calculation: BearBOS = current close < the last confirmed PivotLow(low, pivot lookback, pivot lookback) AND prior close ≥ that pivot low
Calculation: BullOrderblockOverlap = chart bar range intersects any stored zone spanning the low-to-high range of the nearest bearish candle among the preceding orderblock-search lookback bars when a BullBOS occurs on a confirmed bar if confirmation is enabled; retain created zones
Calculation: BearOrderblockOverlap = chart bar range intersects any stored zone spanning the low-to-high range of the nearest bullish candle among the preceding orderblock-search lookback bars when a BearBOS occurs on a confirmed bar if confirmation is enabled; retain created zones
Calculation: BullLiquidityGrab = low < last confirmed PivotLow − RiskATR × liquidity-grab depth AND close > that pivot low AND current bar is confirmed if confirmation is enabled
Calculation: BearLiquidityGrab = high > last confirmed PivotHigh + RiskATR × liquidity-grab depth AND close < that pivot high AND current bar is confirmed if confirmation is enabled
Calculation: MTFScore(T) = on T bars, add a positive vote when EMA(close, fast MTF lookback) > EMA(close, mid MTF lookback), otherwise a negative vote when lower; add a positive vote when close > EMA(close, slow MTF lookback), otherwise a negative vote when lower; add a positive vote when RSI(close, MTF RSI lookback) > MTF bullish RSI threshold, otherwise a negative vote when below MTF bearish RSI threshold; use zero for equalities; fast, mid, and slow MTF EMA lookbacks are ordered shortest to longest; use the current/forming T bar and carry values onto chart bars with lookahead off
Calculation: MTFDirection(T) = 1 when MTF is enabled and MTFScore(T) ≥ MTF direction threshold; −1 when enabled and MTFScore(T) ≤ −MTF direction threshold; otherwise 0
Calculation: BullMTFCount = count of positive MTFDirection values across the four MTF timeframes T2, T3, T4, and T5
Calculation: BearMTFCount = count of negative MTFDirection values across the four MTF timeframes T2, T3, T4, and T5
Calculation: LongBaseScore = full trend weight if BullTrend, else partial trend weight if fast VAEMA > mid VAEMA; plus extreme-long RSI weight if RSI(close, RSI lookback) < (BearTrend ? bearish extreme RSI threshold : oversold threshold), else regular-long RSI weight if (BullTrend ? RSI > bullish mid RSI threshold AND RSI > RSI[slope lookback] : RSI < oversold threshold AND RSI > RSI[slope lookback]); plus strong-long flow weight if BullOBV AND close > VWAP(hlc3, volume, anchored at T1 boundary, chart bars within current T1 period), else above-VWAP weight if close > that VWAP; plus bullish-orderblock-overlap weight if BullOrderblockOverlap, BOS weight if BullBOS, and liquidity-grab weight if BullLiquidityGrab; plus MTF weight × BullMTFCount
Calculation: ShortBaseScore = full trend weight if BearTrend, else partial trend weight if fast VAEMA < mid VAEMA; plus extreme-short RSI weight if RSI(close, RSI lookback) > (BullTrend ? bullish extreme RSI threshold : overbought threshold), else regular-short RSI weight if (BearTrend ? RSI < bearish mid RSI threshold AND RSI < RSI[slope lookback] : RSI > overbought threshold AND RSI < RSI[slope lookback]); plus strong-short flow weight if BearOBV AND close < VWAP(hlc3, volume, anchored at T1 boundary, chart bars within current T1 period), else below-VWAP weight if close < that VWAP; plus bearish-orderblock-overlap weight if BearOrderblockOverlap, BOS weight if BearBOS, and liquidity-grab weight if BearLiquidityGrab; plus MTF weight × BearMTFCount
Calculation: LongScore = clamp(LongBaseScore + lead bonus if LongBaseScore > ShortBaseScore, tie bonus if equal, otherwise zero, between score floor and score ceiling)
Calculation: ShortScore = clamp(ShortBaseScore + lead bonus if ShortBaseScore > LongBaseScore, tie bonus if equal, otherwise zero, between score floor and score ceiling)
Long: BullTrend
Short: BearTrend
Long: MTFDirection(T2) > 0
Short: MTFDirection(T2) < 0
Long: MTFDirection(T3) > 0
Short: MTFDirection(T3) < 0
Long: MTFDirection(T4) > 0
Short: MTFDirection(T4) < 0
Long: MTFDirection(T5) > 0
Short: MTFDirection(T5) < 0
Long: BullBOS
Short: BearBOS
Long: BullLiquidityGrab
Short: BearLiquidityGrab
Long: BullOrderblockOverlap
Short: BearOrderblockOverlap
Long: LongScore ≥ effective score threshold AND LongScore > ShortScore AND LongScore − ShortScore ≥ minimum score gap AND more than cooldown bars since the prior long signal AND current bar is confirmed if confirmation is enabled AND no long signal is active; effective score threshold is the mode-selected threshold unless a positive manual score override is set
Short: ShortScore ≥ effective score threshold AND ShortScore > LongScore AND ShortScore − LongScore ≥ minimum score gap AND more than cooldown bars since the prior short signal AND current bar is confirmed if confirmation is enabled AND no short signal is active; effective score threshold is the mode-selected threshold unless a positive manual score override is set
Exit: Long, low ≤ entry price − RiskATR at entry × stop multiplier OR high ≥ entry price + RiskATR at entry × stop multiplier × first-target reward-to-risk parameter OR bars since entry > time-stop bars
Exit: Short, high ≥ entry price + RiskATR at entry × stop multiplier OR low ≤ entry price − RiskATR at entry × stop multiplier × first-target reward-to-risk parameter OR bars since entry > time-stop bars