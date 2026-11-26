Calculation: LastPivotHigh = most recent non-na Pivot High(high, lookback, lookback)
Calculation: LastPivotLow = most recent non-na Pivot Low(low, lookback, lookback)
Calculation: BullBreak = close crosses above LastPivotHigh AND a Pivot High is non-na after the previous BullBreak bar through the current bar AND at least two Pivot Low values are non-na through the current bar
Calculation: BearBreak = close crosses below LastPivotLow AND a Pivot Low is non-na after the previous BearBreak bar through the current bar AND at least two Pivot High values are non-na through the current bar
Calculation: BullType = CHoCH+ if the last prior break was BearBreak and LastPivotLow > the Pivot Low before it; CHoCH if the last prior break was BearBreak; otherwise BOS
Calculation: BearType = CHoCH+ if the last prior break was BullBreak and LastPivotHigh < the Pivot High before it; CHoCH if the last prior break was BullBreak; otherwise BOS
Calculation: BullOBBottom = lowest T1 low (last completed T1 bar) over chart bars after the most recent Pivot High bar through the current bar
Calculation: BullOBTop = hl2 of the chart bar preceding the bar where BullOBBottom is reached
Calculation: BearOBTop = highest T1 high (last completed T1 bar) over chart bars after the most recent Pivot Low bar through the current bar
Calculation: BearOBBottom = hl2 of the chart bar preceding the bar where BearOBTop is reached
Calculation: BullMitigation = low if mitigation mode is Wick, otherwise close
Calculation: BearMitigation = high if mitigation mode is Wick, otherwise close
Long: BullBreak AND BullMitigation >= BullOBBottom
Long: BullBreak AND BullMitigation >= BullOBBottom AND low crosses below BullOBTop
Long: BullBreak AND BullType is in enabled structure types
Short: BearBreak AND BearMitigation <= BearOBTop
Short: BearBreak AND BearMitigation <= BearOBTop AND high crosses above BearOBBottom
Short: BearBreak AND BearType is in enabled structure types