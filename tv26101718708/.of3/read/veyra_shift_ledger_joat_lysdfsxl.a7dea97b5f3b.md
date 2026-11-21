Calculation: WeightIf(condition, weight) = weight if condition is true, otherwise 0
Calculation: BarRange = max(high - low, tick size)
Calculation: RelativeVolume = volume / SMA(volume, volume baseline lookback)
Calculation: SignedVolume = (close - open) / BarRange * volume
Calculation: PressureIndex = 100 * EMA(SignedVolume, pressure lookback) / EMA(abs(SignedVolume), pressure lookback)
Calculation: DemandAbsorption = low < low[1] AND close > open AND PressureIndex > PressureIndex[1] AND RelativeVolume > absorption volume threshold
Calculation: SupplyAbsorption = high > high[1] AND close < open AND PressureIndex < PressureIndex[1] AND RelativeVolume > absorption volume threshold
Calculation: AuctionHigh = VWMA(hlc3, volume, auction lookback) + StDev(hlc3, auction lookback) * value deviation multiplier
Calculation: AuctionLow = VWMA(hlc3, volume, auction lookback) - StDev(hlc3, auction lookback) * value deviation multiplier
Calculation: DiscountLocation = close < AuctionLow AND close > low + BarRange * auction location fraction
Calculation: PremiumLocation = close > AuctionHigh AND close < high - BarRange * auction location fraction
Calculation: SwingHigh = most recent defined PivotHigh(high, pivot lookback, pivot lookback)
Calculation: SwingLow = most recent defined PivotLow(low, pivot lookback, pivot lookback)
Calculation: DisplacementCandle = abs(close - open) > ATR(ATR lookback) * displacement ATR multiplier AND RelativeVolume > displacement volume threshold
Calculation: BullishBreak = close > SwingHigh AND close[1] <= SwingHigh AND DisplacementCandle
Calculation: BearishBreak = close < SwingLow AND close[1] >= SwingLow AND DisplacementCandle
Calculation: StructureState = 1 if BullishBreak, else -1 if BearishBreak, else StructureState[1], with value 0 on the first bar
Calculation: LowSweep = low < SwingLow AND close > SwingLow
Calculation: HighSweep = high > SwingHigh AND close < SwingHigh
Calculation: BullishGap = low > high[2] AND close > open
Calculation: BearishGap = high < low[2] AND close < open
Calculation: AdxTerm = min(min(ADX(DI lookback, ADX smoothing), ADX ceiling) / ADX divisor, ADX term cap)
Calculation: VolatilityExpansion = PercentRank(ATR(ATR lookback) / close, regime lookback) > expansion threshold
Calculation: HtfLongAllowed = HTF filter disabled OR close > EMA(close, HTF lookback, T1, last completed bar)
Calculation: HtfShortAllowed = HTF filter disabled OR close < EMA(close, HTF lookback, T1, last completed bar)
Calculation: LongEvidence = clamp(WeightIf(EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) > EMA(close, longer EMA lookback) AND close > EMA(close, middle EMA lookback), trend weight) + WeightIf(close > VWAP(hlc3) AND VWAP(hlc3) > VWAP(hlc3)[1], VWAP weight) + WeightIf(MACD histogram(close, shorter MACD lookback, longer MACD lookback, MACD signal lookback) > 0 AND RSI(close, RSI lookback) > RSI bull level AND PlusDI(DI lookback) > MinusDI(DI lookback), momentum weight) + WeightIf(PressureIndex > pressure threshold AND RelativeVolume > pressure volume threshold, pressure weight) + WeightIf(DemandAbsorption, absorption weight) + WeightIf(StructureState = 1 OR LowSweep OR BullishGap, structure weight) + WeightIf(DiscountLocation OR (close > AuctionLow AND close[1] <= AuctionLow[1]), auction weight) + WeightIf(HtfLongAllowed, HTF weight) + WeightIf(VolatilityExpansion AND NOT PremiumLocation, expansion weight) + AdxTerm, 0, 100)
Calculation: ShortEvidence = clamp(WeightIf(EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) < EMA(close, longer EMA lookback) AND close < EMA(close, middle EMA lookback), trend weight) + WeightIf(close < VWAP(hlc3) AND VWAP(hlc3) < VWAP(hlc3)[1], VWAP weight) + WeightIf(MACD histogram(close, shorter MACD lookback, longer MACD lookback, MACD signal lookback) < 0 AND RSI(close, RSI lookback) < RSI bear level AND MinusDI(DI lookback) > PlusDI(DI lookback), momentum weight) + WeightIf(PressureIndex < -pressure threshold AND RelativeVolume > pressure volume threshold, pressure weight) + WeightIf(SupplyAbsorption, absorption weight) + WeightIf(StructureState = -1 OR HighSweep OR BearishGap, structure weight) + WeightIf(PremiumLocation OR (close < AuctionHigh AND close[1] >= AuctionHigh[1]), auction weight) + WeightIf(HtfShortAllowed, HTF weight) + WeightIf(VolatilityExpansion AND NOT DiscountLocation, expansion weight) + AdxTerm, 0, 100)
Long: LongEvidence >= long score threshold AND LongEvidence > ShortEvidence + dominance margin AND HtfLongAllowed AND NOT PremiumLocation
Short: ShortEvidence >= short score threshold AND ShortEvidence > LongEvidence + dominance margin AND HtfShortAllowed AND NOT DiscountLocation
Exit: long, ShortEvidence > LongEvidence OR close < EMA(close, middle EMA lookback) OR (PremiumLocation AND PressureIndex < 0)
Exit: short, LongEvidence > ShortEvidence OR close > EMA(close, middle EMA lookback) OR (DiscountLocation AND PressureIndex > 0)
Long: BullishBreak
Short: BearishBreak
Long: DemandAbsorption
Short: SupplyAbsorption
Long: zone display enabled AND (BullishBreak OR BullishGap OR DemandAbsorption) AND LongEvidence >= zone score threshold AND (StructureState >= 0 OR LowSweep)
Short: zone display enabled AND (BearishBreak OR BearishGap OR SupplyAbsorption) AND ShortEvidence >= zone score threshold AND (StructureState <= 0 OR HighSweep)