Calculation: EMA_shorter = EMA(close, shorter lookback)
Calculation: EMA_middle = EMA(close, middle lookback)
Calculation: EMA_longer = EMA(close, longer lookback)
Calculation: VWAP_T1 = VWAP(typical price, volume), computed on chart bars and restarted when a new T1 bar begins
Calculation: VWAP_T2 = VWAP(typical price, volume), computed on chart bars and restarted when a new T2 bar begins
Calculation: ATR = ATR(high, low, close, ATR length)
Calculation: ADX = ADX(high, low, close, ADX length)
Calculation: CompressionMeasure = (Highest(high, compression lookback) - Lowest(low, compression lookback)) / (ATR * compression lookback)
Calculation: ExpansionRegime = ADX >= ADX floor AND Choppiness(high, low, close, chop length) < chop ceiling AND CompressionMeasure >= compression threshold
Calculation: RelaxedExpansion = ExpansionRegime OR ADX >= ADX floor * soft ADX factor
Calculation: BasisAverage = (EMA_shorter + EMA_middle + EMA_longer) / 3
Calculation: TrendScore = (+1 if EMA_shorter > EMA_middle, else -1) + (+1 if EMA_middle > EMA_longer, else -1) + (+1 if EMA_shorter > EMA_shorter[slope lookback], else -1) + (+1 if EMA_middle > EMA_middle[slope lookback], else -1) + (+1 if close > VWAP_T1, else -1) + (+1 if close > VWAP_T2, else -1) when T2 VWAP toggle is on
Calculation: TrendDirection = 1 if TrendScore >= trend vote threshold; -1 if TrendScore <= -trend vote threshold; else 0
Calculation: MomentumSpread = mean of ZLEMA(RSI(close, ribbon base lookback + ribbon step * k), ribbon smoothing length) over k = 0, 1, 2 minus the same mean over k = 3, 4, 5
Calculation: MomentumDirection = 1 if MomentumSpread > ribbon threshold; -1 if MomentumSpread < -ribbon threshold; else 0
Calculation: LastPivotHigh = most recent non-empty value of PivotHigh(high, pivot strength, pivot strength)
Calculation: LastPivotLow = most recent non-empty value of PivotLow(low, pivot strength, pivot strength)
Calculation: BreakUp = close > LastPivotHigh AND close[1] <= LastPivotHigh
Calculation: BreakDown = close < LastPivotLow AND close[1] >= LastPivotLow
Calculation: StructureState = 1 if the most recent true of BreakUp or BreakDown is BreakUp; -1 if it is BreakDown; 0 if neither has been true
Calculation: HighSweep = high > LastPivotHigh AND close < LastPivotHigh
Calculation: LowSweep = low < LastPivotLow AND close > LastPivotLow
Calculation: VolumeDelta = (close - open) / max(high - low, minimum tick) * volume
Calculation: VolatilityZ = ZScore(ATR, pressure normalization length)
Calculation: PressureIndex = volume-delta weight * ZScore(VolumeDelta, pressure normalization length) + VWAP-deviation weight * ZScore(close - VWAP_T1, pressure normalization length) + basis-distance weight * ZScore(close - BasisAverage, pressure normalization length) - volatility weight * VolatilityZ
Calculation: PressureDirection = 1 if PressureIndex > pressure threshold; -1 if PressureIndex < -pressure threshold; else 0
Calculation: CrowdingIndex = crowding weight * ZScore(RSI(close, crowding RSI length), pressure normalization length) + crowding weight * ZScore(close - VWAP_T2, pressure normalization length)
Calculation: StressLevel = liquidation base + crowding scale * abs(CrowdingIndex) + volatility scale * max(VolatilityZ, 0) + sweep scale when HighSweep OR LowSweep
Calculation: BullScore = expansion points when ExpansionRegime + trend points when TrendDirection = 1 + structure points when StructureState = 1 + break points when BreakUp + sweep points when LowSweep + momentum points when MomentumDirection = 1 + pressure points when PressureDirection = 1 + VWAP points when close > VWAP_T1 + T2 VWAP points when T2 VWAP toggle is on AND close > VWAP_T2 - risk penalty when StressLevel >= risk ceiling
Calculation: BearScore = expansion points when ExpansionRegime + trend points when TrendDirection = -1 + structure points when StructureState = -1 + break points when BreakDown + sweep points when HighSweep + momentum points when MomentumDirection = -1 + pressure points when PressureDirection = -1 + VWAP points when close < VWAP_T1 + T2 VWAP points when T2 VWAP toggle is on AND close < VWAP_T2 - risk penalty when StressLevel >= risk ceiling
Calculation: LongStopLevel = max(entry price - ATR * stop ATR multiple, Highest(high, trail lookback) - ATR * trail ATR multiple) when close >= entry price + ATR * stop ATR multiple * trail trigger R, else entry price - ATR * stop ATR multiple
Calculation: ShortStopLevel = min(entry price + ATR * stop ATR multiple, Lowest(low, trail lookback) + ATR * trail ATR multiple) when close <= entry price - ATR * stop ATR multiple * trail trigger R, else entry price + ATR * stop ATR multiple
Long: position side is not long AND BullScore >= entry threshold AND BullScore >= BearScore - score gap AND RelaxedExpansion AND TrendDirection >= 0 AND MomentumDirection >= 0 AND PressureIndex > -pressure gate AND (BreakUp OR LowSweep OR MomentumSpread crosses above 0 OR close crosses above EMA_shorter) AND StressLevel < soft risk ceiling
Short: position side is not short AND BearScore >= entry threshold AND BearScore >= BullScore - score gap AND RelaxedExpansion AND TrendDirection <= 0 AND MomentumDirection <= 0 AND PressureIndex < pressure gate AND (BreakDown OR HighSweep OR MomentumSpread crosses below 0 OR close crosses below EMA_shorter) AND StressLevel < soft risk ceiling
Exit: long, low <= LongStopLevel
Exit: long, high >= entry price + ATR * target ATR multiple
Exit: long, bias-failure exit toggle AND (TrendDirection != 1 OR MomentumDirection = -1 OR PressureDirection = -1 OR StressLevel >= risk ceiling)
Exit: short, high >= ShortStopLevel
Exit: short, low <= entry price - ATR * target ATR multiple
Exit: short, bias-failure exit toggle AND (TrendDirection != -1 OR MomentumDirection = 1 OR PressureDirection = 1 OR StressLevel >= risk ceiling)