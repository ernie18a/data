Calculation: ChartUp = Supertrend(trend ATR period, trend multiplier) is up
Calculation: FilterUp = Supertrend(trend ATR period, trend multiplier) is up on T1 bars, last completed T1 bar, taken on chart bars
Calculation: FilterDown = Supertrend(trend ATR period, trend multiplier) is down on T1 bars, last completed T1 bar, taken on chart bars
Calculation: TurnUp = ChartUp AND NOT ChartUp[1]
Calculation: TurnDown = NOT ChartUp AND ChartUp[1]
Calculation: MomOsc = EMA((close - MA(close, momentum MA length, momentum MA type)) / ATR(momentum MA length), momentum oscillator smoothing)
Calculation: BuyDiamond = MomOsc crosses above MomOsc[momentum cross lag] AND MomOsc < -momentum threshold
Calculation: SellDiamond = MomOsc crosses below MomOsc[momentum cross lag] AND MomOsc > momentum threshold
Calculation: ScaleATR = ATR(scale ATR length)
Calculation: BuyStar = ChartUp AND ((TurnUp AND barssince(BuyDiamond) <= confluence window) OR (BuyDiamond AND barssince(TurnUp) <= confluence window))
Calculation: SellStar = NOT ChartUp AND ((TurnDown AND barssince(SellDiamond) <= confluence window) OR (SellDiamond AND barssince(TurnDown) <= confluence window))
Calculation: PivotHighBreak(L) = close is above the latest confirmed pivothigh(high, L, L) for the first time since that pivot was confirmed
Calculation: PivotLowBreak(L) = close is below the latest confirmed pivotlow(low, L, L) for the first time since that pivot was confirmed
Calculation: StructureDirection(L) = up if the latest of PivotHighBreak(L) or PivotLowBreak(L) is a high break, down if it is a low break
Calculation: BullZone(L) = on each PivotHighBreak(L) bar where high - low >= displacement multiplier * ScaleATR, the candle with the lowest low from the pivot high bar through the prior bar, looking back at most max zone lookback bars; its low is the bottom and its high is the top
Calculation: BearZone(L) = on each PivotLowBreak(L) bar where high - low >= displacement multiplier * ScaleATR, the candle with the highest high from the pivot low bar through the prior bar, looking back at most max zone lookback bars; its high is the top and its low is the bottom
Calculation: BullMitigation = close or low, per mitigation mode
Calculation: BearMitigation = close or high, per mitigation mode
Calculation: LiveBullZone(L) = a BullZone(L) among the latest max zones per side bullish zones with no earlier bar where BullMitigation is below its bottom
Calculation: LiveBearZone(L) = a BearZone(L) among the latest max zones per side bearish zones with no earlier bar where BearMitigation is above its top
Long: TurnUp
Short: TurnDown
Long: BuyStar AND no earlier BuyStar since the latest TurnUp bar
Short: SellStar AND no earlier SellStar since the latest TurnDown bar
Long: BuyDiamond
Short: SellDiamond
Long: PivotHighBreak(internal pivot length)
Long: PivotHighBreak(swing pivot length)
Short: PivotLowBreak(internal pivot length)
Short: PivotLowBreak(swing pivot length)
Short: BullMitigation below the bottom of any LiveBullZone(internal pivot length)
Long: BearMitigation above the top of any LiveBearZone(internal pivot length)
Short: BullMitigation below the bottom of any LiveBullZone(swing pivot length)
Long: BearMitigation above the top of any LiveBearZone(swing pivot length)
Long: low > high[2] AND close[1] > high[2] AND low - high[2] >= minimum gap multiplier * ScaleATR
Short: high < low[2] AND close[1] < low[2] AND low[2] - high >= minimum gap multiplier * ScaleATR
Short: pivothigh(high, equal pivot length, equal pivot length) is confirmed on this bar AND ABS(pivothigh(high, equal pivot length, equal pivot length) - previous confirmed pivothigh(high, equal pivot length, equal pivot length)) < equal tolerance multiplier * ScaleATR
Long: pivotlow(low, equal pivot length, equal pivot length) is confirmed on this bar AND ABS(pivotlow(low, equal pivot length, equal pivot length) - previous confirmed pivotlow(low, equal pivot length, equal pivot length)) < equal tolerance multiplier * ScaleATR
Long: ChartUp
Short: NOT ChartUp
Long: FilterUp
Short: FilterDown
Long: MomOsc > 0
Short: MomOsc <= 0
Long: StructureDirection(internal pivot length) is up
Short: StructureDirection(internal pivot length) is down
Long: StructureDirection(swing pivot length) is up
Short: StructureDirection(swing pivot length) is down