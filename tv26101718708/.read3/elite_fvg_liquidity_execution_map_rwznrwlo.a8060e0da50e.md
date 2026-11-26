Calculation: PivotHigh(T, L) = High[L] of T bars at the last completed T bar, if High[L] is the highest of High[0] through High[2L]; otherwise none
Calculation: PivotLow(T, L) = Low[L] of T bars at the last completed T bar, if Low[L] is the lowest of Low[0] through Low[2L]; otherwise none
Calculation: Structure = 1 if the latest confirmed PivotHigh(T3, L) exceeds the previous confirmed PivotHigh(T3, L) AND the latest confirmed PivotLow(T3, L) exceeds the previous confirmed PivotLow(T3, L); -1 if both latest values are below their previous values; otherwise 0
Calculation: MedianPrice(T4) = (High[r] + Low[r]) / 2 of T4 bars at the last completed T4 bar
Calculation: BullFVGCreated(T) = a new T bar has just completed AND Low[p] > High[q] of T bars at the last completed T bar (q > p) AND Low[p] - High[q] >= minimum gap AND (session filter disabled OR chart bar is inside session window) AND (bias filter disabled OR Structure = 1 OR (neutral bias passes AND Structure = 0)) AND (PD filter disabled OR (Low[p] + High[q]) / 2 <= MedianPrice(T4)) AND FVG enabled(T)
Calculation: BearFVGCreated(T) = a new T bar has just completed AND High[p] < Low[q] of T bars at the last completed T bar (q > p) AND Low[q] - High[p] >= minimum gap AND (session filter disabled OR chart bar is inside session window) AND (bias filter disabled OR Structure = -1 OR (neutral bias passes AND Structure = 0)) AND (PD filter disabled OR (High[p] + Low[q]) / 2 >= MedianPrice(T4)) AND FVG enabled(T)
Calculation: BullZone(T) = zone with top Low[p] and bottom High[q] of T bars at the last completed T bar, stored from the bar where BullFVGCreated(T) is true and removed after the first bar meeting the mitigation mode's condition: M1 Low <= top; M2 Low <= (top + bottom) / 2; M3 Low <= bottom; under M3, after each bar top = Low if bottom < Low < top; the oldest stored FVG of any direction or timeframe is dropped while stored FVGs exceed the maximum count
Calculation: BearZone(T) = zone with top Low[q] and bottom High[p] of T bars at the last completed T bar, stored from the bar where BearFVGCreated(T) is true and removed after the first bar meeting the mitigation mode's condition: M1 High >= bottom; M2 High >= (top + bottom) / 2; M3 High >= top; under M3, after each bar bottom = High if bottom < High < top
Calculation: SellSideLevel(T) = PivotLow(T, L) value stored on the bar where a new T bar has just completed, if PivotLow(T, L) is not none AND (session filter disabled OR chart bar is inside session window) AND liquidity enabled(T); removed on the first bar where Low <= its price; the oldest stored level of any side is dropped while stored levels exceed the maximum count
Calculation: BuySideLevel(T) = PivotHigh(T, L) value stored on the bar where a new T bar has just completed, if PivotHigh(T, L) is not none AND (session filter disabled OR chart bar is inside session window) AND liquidity enabled(T); removed on the first bar where High >= its price
Calculation: SSLSweep = Low <= price of any stored SellSideLevel(T1 or T3)
Calculation: BSLSweep = High >= price of any stored BuySideLevel(T1 or T3)
Long: BullFVGCreated(T1) OR BullFVGCreated(T2)
Long: Low <= top of any stored BullZone(T1) OR Low <= top of any stored BullZone(T2)
Long: Low <= (top + bottom) / 2 of any stored BullZone(T1) OR Low <= (top + bottom) / 2 of any stored BullZone(T2)
Long: (Low <= top of any stored BullZone(T1) OR Low <= top of any stored BullZone(T2)) AND SSLSweep occurred on this bar or at most W chart bars earlier
Long: Structure = 1
Short: BearFVGCreated(T1) OR BearFVGCreated(T2)
Short: High >= bottom of any stored BearZone(T1) OR High >= bottom of any stored BearZone(T2)
Short: High >= (top + bottom) / 2 of any stored BearZone(T1) OR High >= (top + bottom) / 2 of any stored BearZone(T2)
Short: (High >= bottom of any stored BearZone(T1) OR High >= bottom of any stored BearZone(T2)) AND BSLSweep occurred on this bar or at most W chart bars earlier
Short: Structure = -1