Calculation: BandwidthRank = PercentRank(BBW(close, bb length, bb multiplier), percentile length)
Calculation: BandwidthCompressed = BandwidthRank < compression threshold AND BandwidthRank[earlier offset] < earlier compression threshold
Long: close crosses above Highest(close, donchian length)[1] AND (compression filter off OR BandwidthCompressed[1])
Short: close crosses below Lowest(close, donchian length)[1] AND (compression filter off OR BandwidthCompressed[1])