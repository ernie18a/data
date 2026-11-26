Calculation: rangeLow = Lowest(low, lookbackWindow + 1)
Calculation: rangeHigh = Highest(high, lookbackWindow + 1)
Calculation: bandWidth = (rangeHigh - rangeLow) / bandCount
Calculation: bandIndex(x) = min(bandCount - 1, max(0, floor((x - rangeLow) / bandWidth)))
Calculation: pivotCount(j, type) = number of pivots of type high, low, or any with pivot bar at most lookbackWindow bars back and abs(bandIndex(pivot price) - j) <= binSpread
Calculation: densityPct(j) = 100 * pivotCount(j, any) / max over bins k of pivotCount(k, any)
Calculation: openLevels = levels not yet broken whose pivot bar is at most lookbackWindow bars back, where a pivot price becomes a level on its confirmation bar unless an open level lies within atrMultiple * ATR(atrPeriod) of that price, a high-pivot level breaks when close first crosses above it, and a low-pivot level breaks when close first crosses below it
Long: PivotLow(low, pivotLeftBars, pivotRightBars) is not na
Short: PivotHigh(high, pivotLeftBars, pivotRightBars) is not na
Long: close crosses above a high-pivot level in openLevels
Short: close crosses below a low-pivot level in openLevels
Long: for some bin j from 0 to bandCount - 1, rangeLow + j * bandWidth <= close <= rangeLow + (j + 1) * bandWidth AND densityPct(j) >= densityThreshold AND pivotCount(j, low) > pivotCount(j, high)
Short: for some bin j from 0 to bandCount - 1, rangeLow + j * bandWidth <= close <= rangeLow + (j + 1) * bandWidth AND densityPct(j) >= densityThreshold AND pivotCount(j, high) > pivotCount(j, low)