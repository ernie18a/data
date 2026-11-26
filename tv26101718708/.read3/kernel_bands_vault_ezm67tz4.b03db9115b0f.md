Calculation: AdaptiveBandwidth = base bandwidth * (1 + ATR(atr length) / close * scale factor)
Calculation: KernelMA = (sum over i from 0 to kernel lookback - 1 of K(i) * source[i]) / (sum over the same i of K(i)), where K(i) is exp(-i^2 / (2 * AdaptiveBandwidth^2)) for kernel type Gaussian, max(0, 1 - i^2 / AdaptiveBandwidth^2) for kernel type Epanechnikov, and max(0, (1 - ABS(i / AdaptiveBandwidth)^3)^3) for kernel type Tricube
Calculation: KernelSlopeUp = KernelMA > KernelMA[1]
Calculation: ResidualSD = EMA(STDEV(source - KernelMA, sigma length), sigma smoothing)
Calculation: BandHalfWidth = max(ResidualSD * sigma multiplier, ATR(atr length) * band floor)
Calculation: UpperBand = KernelMA + BandHalfWidth
Calculation: LowerBand = KernelMA - BandHalfWidth
Calculation: BandState = 1 if the latest upper bar is more recent than the latest lower bar, -1 if the latest lower bar is more recent, 0 if neither exists, where an upper bar is a bar where close > UpperBand holds for each of the last confirmation closes bars, a lower bar is a bar where close < LowerBand holds for each of the last confirmation closes bars, and an absent bar counts as oldest
Calculation: BandStateFlipUp = BandState == 1 AND BandState[1] != 1
Calculation: BandStateFlipDown = BandState == -1 AND BandState[1] != -1
Calculation: BarRange = high - low
Calculation: BarBody = ABS(close - open)
Calculation: BlowOffBar = max(BarRange, BarRange[1]) > ATR(atr length) * blow-off multiple
Calculation: ChopShieldOn = (flat slope weight * IF(ABS(KernelMA - KernelMA[flat slope window]) < ATR(atr length) * flat slope factor, 1, 0) + tight range weight * IF(HIGHEST(high, range window) - LOWEST(low, range window) < ATR(atr length) * tight range factor, 1, 0) + cluster weight * IF(COUNT(BandState != BandState[1] over flip window) >= minimum flips, 1, 0) + weak volume weight * IF(SMA(volume, volume window) > 0 AND volume < SMA(volume, volume window) * weak volume factor, 1, 0)) >= chop trigger score
Calculation: ChopShieldReleased = ChopShieldOn[1] AND NOT ChopShieldOn
Calculation: EntryFiltersPass = (bar datetime in London window OR bar datetime in New York window) AND NOT ChopShieldOn AND NOT BlowOffBar AND bars since last entry >= minimum bars between entries
Calculation: LongSetupTriggered = BandState == 1 AND position side is not long AND (BandStateFlipUp OR ChopShieldReleased OR (position side is flat AND close crosses above KernelMA AND KernelSlopeUp))
Calculation: ShortSetupTriggered = BandState == -1 AND position side is not short AND (BandStateFlipDown OR ChopShieldReleased OR (position side is flat AND close crosses below KernelMA AND NOT KernelSlopeUp))
Calculation: LongSetupArmed = the latest LongSetupTriggered bar is within the last entry wait window bars AND BandState == 1 on every bar from that bar through the current bar AND no long entry on any bar from that bar through the previous bar
Calculation: ShortSetupArmed = the latest ShortSetupTriggered bar is within the last entry wait window bars AND BandState == -1 on every bar from that bar through the current bar AND no short entry on any bar from that bar through the previous bar
Calculation: OpenProfitPips = (close - entry price) / pip size if position side is long, (entry price - close) / pip size if position side is short, else 0
Calculation: PeakProfitPips = max(0, OpenProfitPips on each bar since entry through the current bar)
Calculation: TopReversalCandle = BarRange > 0 AND (BarBody <= doji fraction * BarRange OR ((high - max(open, close)) >= wick to body ratio * BarBody AND (high - max(open, close)) >= wick fraction * BarRange) OR (close < open AND open >= close[1] AND close <= open[1] AND BarBody > BarBody[1])) AND high >= UpperBand AND no TopReversalCandle or BottomReversalCandle within the previous reversal cooldown bars
Calculation: BottomReversalCandle = BarRange > 0 AND (BarBody <= doji fraction * BarRange OR ((min(open, close) - low) >= wick to body ratio * BarBody AND (min(open, close) - low) >= wick fraction * BarRange) OR (close > open AND open <= close[1] AND close >= open[1] AND BarBody > BarBody[1])) AND low <= LowerBand AND no TopReversalCandle or BottomReversalCandle within the previous reversal cooldown bars
Calculation: BullishDivergence = source - source[divergence slope window] < -(ATR(atr length) * divergence slope window * minimum price slope factor) AND KernelMA - KernelMA[divergence slope window] > ATR(atr length) * divergence slope window * minimum kernel slope factor AND no BullishDivergence or BearishDivergence within the previous divergence cooldown bars
Calculation: BearishDivergence = source - source[divergence slope window] > ATR(atr length) * divergence slope window * minimum price slope factor AND KernelMA - KernelMA[divergence slope window] < -(ATR(atr length) * divergence slope window * minimum kernel slope factor) AND no BullishDivergence or BearishDivergence within the previous divergence cooldown bars
Calculation: TFBandState(T) = BandState computed on T bars using the still-forming bar, read onto chart bars
Calculation: OtherTFBandState(T) = BandState of the other instrument computed on T bars using the still-forming bar, read onto chart bars
Long: LongSetupArmed AND position side is not long AND EntryFiltersPass AND close - UpperBand <= maximum extension * BandHalfWidth AND KernelSlopeUp AND close > open
Short: ShortSetupArmed AND position side is not short AND EntryFiltersPass AND LowerBand - close <= maximum extension * BandHalfWidth AND NOT KernelSlopeUp AND close < open
Exit: long, BandStateFlipDown OR (TopReversalCandle AND OpenProfitPips > 0) OR (PeakProfitPips >= minimum peak pips AND OpenProfitPips <= PeakProfitPips * (1 - giveback percent / 100)) OR (close < LOWEST(low, structure lookback)[1] AND OpenProfitPips > 0)
Exit: short, BandStateFlipUp OR (BottomReversalCandle AND OpenProfitPips > 0) OR (PeakProfitPips >= minimum peak pips AND OpenProfitPips <= PeakProfitPips * (1 - giveback percent / 100)) OR (close > HIGHEST(high, structure lookback)[1] AND OpenProfitPips > 0)
Long: BottomReversalCandle
Short: TopReversalCandle
Long: BullishDivergence
Short: BearishDivergence
Long: BandStateFlipUp
Short: BandStateFlipDown
Long: KernelSlopeUp AND NOT KernelSlopeUp[1]
Short: NOT KernelSlopeUp AND KernelSlopeUp[1]
Long: BandState == 1
Short: BandState == -1
Long: KernelSlopeUp
Short: NOT KernelSlopeUp
Long: BottomReversalCandle occurred within the last reversal display age bars AND no TopReversalCandle occurred after that bar
Short: TopReversalCandle occurred within the last reversal display age bars AND no BottomReversalCandle occurred after that bar
Long: BullishDivergence occurred within the last divergence cooldown bars AND no BearishDivergence occurred after that bar
Short: BearishDivergence occurred within the last divergence cooldown bars AND no BullishDivergence occurred after that bar
Long: LongSetupArmed AND position side is flat
Short: ShortSetupArmed AND position side is flat
Long: TFBandState(T1) == 1
Long: TFBandState(T2) == 1
Long: TFBandState(T3) == 1
Long: TFBandState(T4) == 1
Long: TFBandState(T1) == 1 AND TFBandState(T2) == 1 AND TFBandState(T3) == 1 AND TFBandState(T4) == 1
Short: TFBandState(T1) == -1
Short: TFBandState(T2) == -1
Short: TFBandState(T3) == -1
Short: TFBandState(T4) == -1
Short: TFBandState(T1) != 1 AND TFBandState(T2) != 1 AND TFBandState(T3) != 1 AND TFBandState(T4) != 1
Long: OtherTFBandState(T1) == 1
Long: OtherTFBandState(T2) == 1
Long: OtherTFBandState(T3) == 1
Long: OtherTFBandState(T4) == 1
Long: OtherTFBandState(T1) == 1 AND OtherTFBandState(T2) == 1 AND OtherTFBandState(T3) == 1 AND OtherTFBandState(T4) == 1
Short: OtherTFBandState(T1) == -1
Short: OtherTFBandState(T2) == -1
Short: OtherTFBandState(T3) == -1
Short: OtherTFBandState(T4) == -1
Short: OtherTFBandState(T1) != 1 AND OtherTFBandState(T2) != 1 AND OtherTFBandState(T3) != 1 AND OtherTFBandState(T4) != 1