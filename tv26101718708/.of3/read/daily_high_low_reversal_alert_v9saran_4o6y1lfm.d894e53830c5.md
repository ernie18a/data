Calculation: BodyTop = max(open, close)
Calculation: BodyBottom = min(open, close)
Calculation: BodySize = BodyTop - BodyBottom
Calculation: CandleRange = high - low
Calculation: UpperShadow = high - BodyTop
Calculation: LowerShadow = BodyBottom - low
Calculation: WithinTolerance(price, level) = level > 0 AND abs(price - level) / level * 100 <= proximity tolerance
Calculation: ExtensionBars = extension parameter for chart timeframe T2 when chart timeframe is T2, for T3 when it is T3, for T4 when it is T4, and the other-timeframe parameter otherwise
Calculation: ActiveDailyLevels = the most recent retained-day-count pairs of T1 high and low, read on chart bars with lookahead off from the still-forming T1 bar and captured once per New York date when capture-start-time <= New York time < capture-end-time; a level remains active while its age in chart bars <= ExtensionBars
Calculation: Hammer = (CandleRange > 0 AND LowerShadow >= major-wick-minimum ratio * CandleRange AND BodySize <= body-maximum ratio * CandleRange AND UpperShadow <= minor-wick-maximum ratio * CandleRange) OR (CandleRange > 0 AND close >= close-to-high factor * high AND LowerShadow >= special-wick-minimum ratio * CandleRange AND UpperShadow <= minor-wick-maximum ratio * CandleRange)
Calculation: InvertedHammer = (CandleRange > 0 AND UpperShadow >= major-wick-minimum ratio * CandleRange AND BodySize <= body-maximum ratio * CandleRange AND LowerShadow <= minor-wick-maximum ratio * CandleRange) OR (CandleRange > 0 AND open <= open-to-low factor * low AND UpperShadow >= special-wick-minimum ratio * CandleRange AND LowerShadow <= minor-wick-maximum ratio * CandleRange)
Long: New York time >= market-start-time AND New York time < market-end-time AND (Hammer OR InvertedHammer) AND (WithinTolerance(high, any active daily high) OR WithinTolerance(low, any active daily low) OR (manual levels enabled AND (WithinTolerance(high, any of ManualLevel1–ManualLevel5) OR WithinTolerance(low, any of ManualLevel1–ManualLevel5))))