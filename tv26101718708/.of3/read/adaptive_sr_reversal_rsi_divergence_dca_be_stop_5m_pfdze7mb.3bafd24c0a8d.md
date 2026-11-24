Calculation: T1High(n) = Highest(high, n) over T1 bars, last completed bar, read onto chart bars
Calculation: T1Low(n) = Lowest(low, n) over T1 bars, last completed bar, read onto chart bars
Calculation: BandRange(n) = (T1High(n) - T1Low(n)) / T1Low(n)
Calculation: Lookback = smallest n from 1 to maxLookback, stepping by 1, with BandRange(n) >= minRange, else maxLookback
Calculation: Resistance = T1High(Lookback)
Calculation: Support = T1Low(Lookback)
Calculation: Midpoint = (Resistance + Support) / 2
Calculation: BullishDivergence = a PivotLow(low, pivotLeft, pivotRight) is confirmed on this bar AND its value < value of the previous confirmed PivotLow AND RSI(close, rsiLength)[pivotRight] > RSI(close, rsiLength) at the bar of the previous confirmed PivotLow
Calculation: BearishDivergence = a PivotHigh(high, pivotLeft, pivotRight) is confirmed on this bar AND its value > value of the previous confirmed PivotHigh AND RSI(close, rsiLength)[pivotRight] < RSI(close, rsiLength) at the bar of the previous confirmed PivotHigh
Calculation: Fills = number of entry fills since the position opened
Calculation: ExitsToday = number of position exits so far on the current UTC day
Calculation: FavPct = (close - first entry price) / first entry price for long; (first entry price - close) / first entry price for short
Calculation: BreakevenArmed = FavPct >= beTrigger on the current bar or any earlier bar since the position opened
Calculation: HoldDay = UTC day of the first bar at or after closeHour since the position opened, if FavPct on that bar >= holdMin, else none
Calculation: LongStop = if BreakevenArmed then max(last entry price * (1 - slPct), first entry price * (1 + beBuffer)) else last entry price * (1 - slPct)
Calculation: ShortStop = if BreakevenArmed then min(last entry price * (1 + slPct), first entry price * (1 - beBuffer)) else last entry price * (1 + slPct)
Calculation: LongTarget = if Fills > 1 then first entry price * (1 + tpPostPct) else Midpoint * (1 - tpOffset)
Calculation: ShortTarget = if Fills > 1 then first entry price * (1 - tpPostPct) else Midpoint * (1 + tpOffset)
Long: no position open AND ExitsToday < cycleLimit AND hour(UTC) < closeHour AND low <= Support * (1 + touchZone) AND low > Support * (1 - maxBreach) AND volume >= volumeMult * SMA(volume, volumeLength) AND BullishDivergence is true on the current bar or on any of the previous freshBars bars
Long: BullishDivergence
Long: position is long AND Fills < dcaLevels AND low <= last entry price * (1 - dcaSpacing)
Short: no position open AND ExitsToday < cycleLimit AND hour(UTC) < closeHour AND high >= Resistance * (1 - touchZone) AND high < Resistance * (1 + maxBreach) AND volume >= volumeMult * SMA(volume, volumeLength) AND BearishDivergence is true on the current bar or on any of the previous freshBars bars
Short: BearishDivergence
Short: position is short AND Fills < dcaLevels AND high >= last entry price * (1 + dcaSpacing)
Exit: long, low <= LongStop OR high >= LongTarget OR (hour(UTC) >= closeHour AND HoldDay is not the current UTC day)
Exit: short, high >= ShortStop OR low <= ShortTarget OR (hour(UTC) >= closeHour AND HoldDay is not the current UTC day)