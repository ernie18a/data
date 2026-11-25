Calculation: OpeningHigh(O) = max(high) over chart bars inside session O since session O last started
Calculation: OpeningLow(O) = min(low) over chart bars inside session O since session O last started
Calculation: HighBroken(P, O) = true from the first chart bar inside session P with high > OpeningHigh(O) until session P ends, and false outside session P
Calculation: LowBroken(P, O) = true from the first chart bar inside session P with low < OpeningLow(O) until session P ends, and false outside session P
Calculation: HighSweep(P, O) = HighBroken(P, O) AND NOT HighBroken(P, O)[1] AND NOT LowBroken(P, O)
Calculation: LowSweep(P, O) = LowBroken(P, O) AND NOT LowBroken(P, O)[1] AND NOT HighBroken(P, O)
Calculation: BearLevel(P, O, N) = on each HighSweep(P, O) bar, min(open[i-1], open[i-2]) where i is the offset of the most recent bar within N bars with close < open (open[0] when i = 1), held until session P ends
Calculation: BearLevelAge(P, O, N) = bars since the bar whose open gives BearLevel(P, O, N), taking the older bar on a tie
Calculation: BullLevel(P, O, N) = on each LowSweep(P, O) bar, max(open[i-1], open[i-2]) where i is the offset of the most recent bar within N bars with close > open (open[0] when i = 1), held until session P ends
Calculation: BullLevelAge(P, O, N) = bars since the bar whose open gives BullLevel(P, O, N), taking the older bar on a tie
Calculation: BearCISD(P, O, N, S) = true only on the first bar from the HighSweep(P, O) bar onward, inside session P, with close <= BearLevel(P, O, N) and BearLevelAge(P, O, N) <= S
Calculation: BullCISD(P, O, N, S) = true only on the first bar from the LowSweep(P, O) bar onward, inside session P, with close >= BullLevel(P, O, N) and BullLevelAge(P, O, N) <= S
Calculation: BullGap = low > high[2]
Calculation: BearGap = high < low[2]
Calculation: SupplyFVGPresent(P, O) = true when a stack is non-empty; the stack is built from the HighSweep(P, O) bar onward, inside session P, where each bar first pushes high if BearGap is true and passes the FVG filter, then pops the top entry once if high > top entry
Calculation: DemandFVGPresent(P, O) = true when a stack is non-empty; the stack is built from the LowSweep(P, O) bar onward, inside session P, where each bar first pushes low if BullGap is true and passes the FVG filter, then pops the top entry once if low < top entry
Calculation: DispRange = abs(close - open) when displacement type is open-to-close, else high - low
Calculation: PriorHigh(T) = high of the last completed bar of timeframe T, read on chart bars
Calculation: PriorLow(T) = low of the last completed bar of timeframe T, read on chart bars
Calculation: SessionHigh(S) = max(high) over chart bars inside session S during its most recent completed occurrence
Calculation: SessionLow(S) = min(low) over chart bars inside session S during its most recent completed occurrence
Calculation: SweepHigh(L) = true only on the first bar since level L last changed with high > L and close < L
Calculation: SweepLow(L) = true only on the first bar since level L last changed with low < L and close > L
Calculation: PremarketHigh = max(high) over chart bars inside the premarket session during its most recent completed occurrence
Calculation: PremarketLow = min(low) over chart bars inside the premarket session during its most recent completed occurrence
Calculation: GridLevel(k) = PremarketLow + (PremarketHigh - PremarketLow) * k / 8
Calculation: UpTapCount(k) = increases by 1 on a bar with high >= GridLevel(k) and max(open, close) < GridLevel(k); unchanged on a bar with high < GridLevel(k); otherwise set to 0; reset to 0 each day
Calculation: DownTapCount(k) = increases by 1 on a bar with low <= GridLevel(k) and min(open, close) > GridLevel(k); unchanged on a bar with low > GridLevel(k); otherwise set to 0; reset to 0 each day
Calculation: UpRejection(k) = true on a bar where UpTapCount(k) = taps and, when the once-per-day switch is on, UpTapCount(k) has not earlier that day equaled taps
Calculation: DownRejection(k) = true on a bar where DownTapCount(k) = taps and, when the once-per-day switch is on, DownTapCount(k) has not earlier that day equaled taps
Calculation: PremarketEfficiency = abs(close at premarket session end - open at premarket session start) / (sum of abs(close - close[1]) over premarket bars after the first) * sqrt(premarket bar count - 1)
Calculation: PremarketClosePosition = (close at premarket session end - PremarketLow) / (PremarketHigh - PremarketLow)
Calculation: MedianPremarketRange = median of premarket ranges from earlier days, defined once at least Mh are recorded
Calculation: KeyLevelDistance = smallest distance among PriorHigh(T1), PriorHigh(T2), PriorHigh(T3), SessionHigh(Asia session), SessionHigh(London session), measured from PremarketHigh, and PriorLow(T1), PriorLow(T2), PriorLow(T3), SessionLow(Asia session), SessionLow(London session), measured from PremarketLow, that lie inside the premarket range; infinite when none does
Calculation: TrendFactorCount = count of true among PremarketEfficiency >= E, PremarketClosePosition >= C or PremarketClosePosition <= 1 - C, and PremarketHigh - PremarketLow >= X * MedianPremarketRange
Calculation: ConsolidationScore = min(100, Wt * [TrendFactorCount >= R] + Wn * [KeyLevelDistance <= Pk * (PremarketHigh - PremarketLow)] + Ws * [KeyLevelDistance <= Sh * (PremarketHigh - PremarketLow)] + Ww * [PremarketHigh - PremarketLow >= Wm * MedianPremarketRange]), where [x] is 1 if x holds else 0, evaluated at premarket session end and held until the next one
Long: BullCISD(P1, O1, N, S1) = true
Short: BearCISD(P1, O1, N, S1) = true
Long: BullCISD(P1, O1, N, S1) = true AND DemandFVGPresent(P1, O1) = true
Short: BearCISD(P1, O1, N, S1) = true AND SupplyFVGPresent(P1, O1) = true
Long: BullCISD(P2, O2, N, S2) = true
Short: BearCISD(P2, O2, N, S2) = true
Long: BullCISD(P2, O2, N, S2) = true AND DemandFVGPresent(P2, O2) = true
Short: BearCISD(P2, O2, N, S2) = true AND SupplyFVGPresent(P2, O2) = true
Long: BullCISD(P3, O3, N, S2) = true
Short: BearCISD(P3, O3, N, S2) = true
Long: BullCISD(P3, O3, N, S2) = true AND DemandFVGPresent(P3, O3) = true
Short: BearCISD(P3, O3, N, S2) = true AND SupplyFVGPresent(P3, O3) = true
Long: close[1] > open[1] AND DispRange[1] > DX * StDev(DispRange, DL)[1] AND BullGap = true AND (displacement window switch off OR bar inside P1, P2 or P3)
Short: close[1] < open[1] AND DispRange[1] > DX * StDev(DispRange, DL)[1] AND BearGap = true AND (displacement window switch off OR bar inside P1, P2 or P3)
Long: BullGap = true AND min(open, close) > max(open[1], close[1]) AND min(open[1], close[1]) > max(open[2], close[2]) AND low - high[2] >= Gmin AND bar in suspension scope (all bars, RTH session, or inside P1, P2 or P3)
Short: BearGap = true AND min(open[2], close[2]) > max(open[1], close[1]) AND max(open, close) < min(open[1], close[1]) AND low[2] - high >= Gmin AND bar in suspension scope (all bars, RTH session, or inside P1, P2 or P3)
Short: SweepHigh(PriorHigh(T1)) = true
Short: SweepHigh(PriorHigh(T2)) = true
Short: SweepHigh(PriorHigh(T3)) = true
Short: SweepHigh(SessionHigh(Asia session)) = true
Short: SweepHigh(SessionHigh(London session)) = true
Long: SweepLow(PriorLow(T1)) = true
Long: SweepLow(PriorLow(T2)) = true
Long: SweepLow(PriorLow(T3)) = true
Long: SweepLow(SessionLow(Asia session)) = true
Long: SweepLow(SessionLow(London session)) = true
Short: close crosses above GridLevel(4)
Long: close crosses below GridLevel(4)
Short: for some tested level k, UpRejection(k) = true
Long: for some tested level k, DownRejection(k) = true
Short: for some tested level k, UpRejection(k) = true AND NOT (regime gate switch on AND ConsolidationScore >= Tc)
Long: for some tested level k, DownRejection(k) = true AND NOT (regime gate switch on AND ConsolidationScore >= Tc)