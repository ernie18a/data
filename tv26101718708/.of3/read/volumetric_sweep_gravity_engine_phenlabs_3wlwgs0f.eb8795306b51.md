Calculation: SSL = last non-NA value of PivotLow(low, swing length, swing length)
Calculation: BSL = last non-NA value of PivotHigh(high, swing length, swing length)
Calculation: Volatility = ATR(ATR length)
Calculation: VolatilityBase = SMA(Volatility, ATR average length), where ATR average length is longer than ATR length
Calculation: VolumeRel = volume / SMA(volume, volume length)
Calculation: DeltaRaw = (high - low) > 0 ? volume * (close - open) / (high - low) : 0
Calculation: DeltaRel = abs(SMA(DeltaRaw, volume length)) > 0 ? DeltaRaw / abs(SMA(DeltaRaw, volume length)) : 0
Calculation: LowerTail = min(open, close) - low
Calculation: UpperTail = high - max(open, close)
Calculation: Body = abs(close - open)
Calculation: LowerTailRatio = Body > 0 ? LowerTail / Body : (LowerTail > 0 ? zero-body wick ratio : 0)
Calculation: UpperTailRatio = Body > 0 ? UpperTail / Body : (UpperTail > 0 ? zero-body wick ratio : 0)
Calculation: LongScore = (volume weight * min(100, 100 * VolumeRel / (volume multiplier * volume soft-cap factor)) + wick weight * min(100, 100 * LowerTailRatio / (minimum wick-to-body ratio * wick soft-cap factor)) + delta weight * min(100, 100 * max(DeltaRel, 0) / delta soft-cap)) / (volume weight + wick weight + delta weight, or 1 if that sum is 0)
Calculation: ShortScore = (volume weight * min(100, 100 * VolumeRel / (volume multiplier * volume soft-cap factor)) + wick weight * min(100, 100 * UpperTailRatio / (minimum wick-to-body ratio * wick soft-cap factor)) + delta weight * min(100, 100 * max(-DeltaRel, 0) / delta soft-cap)) / (volume weight + wick weight + delta weight, or 1 if that sum is 0)
Long: low < SSL - Volatility * sweep buffer AND LowerTail >= Volatility * minimum sweep wick AND (not require close back inside OR close > SSL) AND low < low[1] AND Volatility > 0 AND (not use ATR filter OR Volatility >= VolatilityBase * ATR floor multiplier) AND (not use EMA trend filter OR close > EMA(close, trend length)) AND VolumeRel >= volume multiplier AND LowerTailRatio >= minimum wick-to-body ratio AND LongScore >= minimum absorption score
Short: high > BSL + Volatility * sweep buffer AND UpperTail >= Volatility * minimum sweep wick AND (not require close back inside OR close < BSL) AND high > high[1] AND Volatility > 0 AND (not use ATR filter OR Volatility >= VolatilityBase * ATR floor multiplier) AND (not use EMA trend filter OR close < EMA(close, trend length)) AND VolumeRel >= volume multiplier AND UpperTailRatio >= minimum wick-to-body ratio AND ShortScore >= minimum absorption score