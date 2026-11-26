Calculation: BaseCount = largest n <= MaxBase such that high[k] - low[k] <= BaseRatio * (high - low) for every k = 1..n, on Tn bars
Calculation: BaseHigh = max(high[k]) for k = 1..BaseCount
Calculation: BaseLow = min(low[k]) for k = 1..BaseCount
Calculation: ZoneTop = (BaseHigh + BaseLow) / 2 + ZoneMult * (BaseHigh - BaseLow) / 2
Calculation: ZoneBottom = (BaseHigh + BaseLow) / 2 - ZoneMult * (BaseHigh - BaseLow) / 2
Calculation: WickPrice = low for a demand zone, high for a supply zone
Calculation: RetestPrice = close, or WickPrice, per the retest-trigger parameter
Calculation: BreakPrice = close, or WickPrice, per the invalidation parameter
Calculation: Overlap(A, B) = max(0, min(A.top, B.top) - max(A.bottom, B.bottom)) / min(A.top - A.bottom, B.top - B.bottom)
Calculation: Tracked(zone) = zone is not broken and not dropped, where a zone of Tn is dropped when a zone of Tn is created while more than MaxPerTf zones of Tn are tracked and it is the oldest tracked zone of Tn
Long: on Tn last completed bar, close > open AND close - open > BodyFrac * (high - low) AND high - low > ImpulseMult * ATR(ATRLength, Tn, last completed bar) AND BaseCount >= MinBase AND BaseHigh - BaseLow > 0 AND MinHeight * ATR(ATRLength, Tn, last completed bar) <= BaseHigh - BaseLow AND BaseHigh - BaseLow <= MaxHeight * ATR(ATRLength, Tn, last completed bar) AND Tn is not shorter than chart timeframe AND NOT (SkipOverlap AND some tracked demand zone Z has Overlap(new zone, Z) > MergeThreshold)
Short: on Tn last completed bar, close < open AND open - close > BodyFrac * (high - low) AND high - low > ImpulseMult * ATR(ATRLength, Tn, last completed bar) AND BaseCount >= MinBase AND BaseHigh - BaseLow > 0 AND MinHeight * ATR(ATRLength, Tn, last completed bar) <= BaseHigh - BaseLow AND BaseHigh - BaseLow <= MaxHeight * ATR(ATRLength, Tn, last completed bar) AND Tn is not shorter than chart timeframe AND NOT (SkipOverlap AND some tracked supply zone Z has Overlap(new zone, Z) > MergeThreshold)
Long: some tracked demand zone has BreakPrice >= ZoneBottom AND RetestPrice <= ZoneTop AND some bar from its creation or last retest up to the previous bar had low > ZoneTop
Short: some tracked supply zone has BreakPrice <= ZoneTop AND RetestPrice >= ZoneBottom AND some bar from its creation or last retest up to the previous bar had high < ZoneBottom
Exit: long, some tracked demand zone has BreakPrice < ZoneBottom
Exit: short, some tracked supply zone has BreakPrice > ZoneTop