Calculation: SignalOpen = open of the last completed bar of the signal timeframe
Calculation: UpperLevel = EMA(highest(SignalOpen, upperLookback), upperEmaLength)
Calculation: LowerLevel = EMA(lowest(SignalOpen, lowerLookback), lowerEmaLength)
Long: SMA(UpperLevel, upperShortSmaLength) crosses under SMA(UpperLevel, upperLongSmaLength), where upperShortSmaLength is shorter than upperLongSmaLength
Short: SMA(LowerLevel, lowerShortSmaLength) crosses over SMA(LowerLevel, lowerLongSmaLength), where lowerShortSmaLength is shorter than lowerLongSmaLength