Calculation: SwingHigh = most recent non-NA value of PivotHigh(high, pivot length, pivot length)
Calculation: SwingLow = most recent non-NA value of PivotLow(low, pivot length, pivot length)
Calculation: BullBreak = close crosses above SwingHigh[1] AND no BullBreak has occurred since SwingHigh was last set
Calculation: BearBreak = close crosses below SwingLow[1] AND no BearBreak has occurred since SwingLow was last set
Calculation: BreakDirection = 1 if BullBreak, -1 if BearBreak, otherwise BreakDirection[1]
Calculation: ZoneHigh = Highest(high, zone lookback) for lookback zones, or Highest(high, chart bars from the start of the current still-forming T1 bar through the current bar) for session zones
Calculation: ZoneLow = Lowest(low, zone lookback) for lookback zones, or Lowest(low, chart bars from the start of the current still-forming T1 bar through the current bar) for session zones
Long: BullBreak = true
Short: BearBreak = true
Long: BreakDirection = 1
Short: BreakDirection = -1
Long: PivotHigh(high, pivot length, pivot length) > SwingHigh[1]
Short: PivotHigh(high, pivot length, pivot length) <= SwingHigh[1]
Long: PivotLow(low, pivot length, pivot length) > SwingLow[1]
Short: PivotLow(low, pivot length, pivot length) <= SwingLow[1]
Long: low > high[n]
Short: high < low[n]
Long: close <= ZoneLow + discount fraction * (ZoneHigh - ZoneLow)
Short: close >= ZoneLow + premium fraction * (ZoneHigh - ZoneLow)