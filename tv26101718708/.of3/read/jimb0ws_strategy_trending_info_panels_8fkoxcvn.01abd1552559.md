Calculation: UpperBody = max(open, close)
Calculation: LowerBody = min(open, close)
Calculation: LongBubble = EMA(close, shorter lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longer lookback)
Calculation: ShortBubble = EMA(close, shorter lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longer lookback)
Calculation: LongTouch(X) = ((LowerBody <= X + body tolerance AND LowerBody >= X - body drive) OR (low <= X + wick tolerance AND low >= X - wick drive)) AND close > X
Calculation: ShortTouch(X) = ((UpperBody >= X - body tolerance AND UpperBody <= X + body drive) OR (high >= X - wick tolerance AND high <= X + wick drive)) AND close < X
Calculation: LongGolden = LongBubble AND UpperBody - LowerBody >= minimum body size AND (LongTouch(EMA(close, shorter lookback)) OR LongTouch(EMA(close, middle lookback))) AND NOT low < EMA(close, middle lookback) - overdrive distance
Calculation: ShortGolden = ShortBubble AND UpperBody - LowerBody >= minimum body size AND (ShortTouch(EMA(close, shorter lookback)) OR ShortTouch(EMA(close, middle lookback))) AND NOT high > EMA(close, middle lookback) + overdrive distance
Calculation: LongStop = MIN(EMA(close, longer lookback), EMA(close, longest lookback))
Calculation: ShortStop = MAX(EMA(close, longer lookback), EMA(close, longest lookback))
Calculation: T1Block = (EMA(close, shorter lookback, T1, last completed bar) < EMA(close, middle lookback, T1, last completed bar) AND EMA(close, middle lookback, T1, last completed bar) < EMA(close, longer lookback, T1, last completed bar) AND close > EMA(close, middle lookback, T1, bar still forming)) OR (EMA(close, shorter lookback, T1, last completed bar) > EMA(close, middle lookback, T1, last completed bar) AND EMA(close, middle lookback, T1, last completed bar) > EMA(close, longer lookback, T1, last completed bar) AND close < EMA(close, middle lookback, T1, bar still forming))
Calculation: NearT1Mid = close >= EMA(close, middle lookback, T1, bar still forming) - proximity range AND close <= EMA(close, middle lookback, T1, bar still forming) + proximity range
Calculation: LongEntryCount = number of bars from the latest bar where LongBubble became true through the previous bar on which the Long entry condition held
Calculation: ShortEntryCount = number of bars from the latest bar where ShortBubble became true through the previous bar on which the Short entry condition held
Long: LongGolden[2] AND PivotLow(low, pivot left bars, pivot right bars) is defined AND UpperBody[1] >= UpperBody[2] AND bar datetime within session window AND LongEntryCount < max signals per bubble AND NOT T1Block AND NOT NearT1Mid
Long: LongBubble
Long: LongGolden
Long: LongBubble AND LongGolden[1] AND UpperBody > UpperBody[1]
Long: LongBubble AND PivotLow(low, pivot left bars, pivot right bars) is defined
Long: EMA(close, shorter lookback, T1, bar still forming) > EMA(close, middle lookback, T1, bar still forming) AND EMA(close, middle lookback, T1, bar still forming) > EMA(close, longer lookback, T1, bar still forming)
Long: EMA(close, shorter lookback, T2, bar still forming) > EMA(close, middle lookback, T2, bar still forming) AND EMA(close, middle lookback, T2, bar still forming) > EMA(close, longer lookback, T2, bar still forming)
Exit: Long, low <= LongStop at entry bar OR high >= entry price + reward-to-risk ratio * (entry price - LongStop at entry bar)
Short: ShortGolden[2] AND PivotHigh(high, pivot left bars, pivot right bars) is defined AND LowerBody[1] <= LowerBody[2] AND bar datetime within session window AND ShortEntryCount < max signals per bubble AND NOT T1Block AND NOT NearT1Mid
Short: ShortBubble
Short: ShortGolden
Short: ShortBubble AND ShortGolden[1] AND LowerBody < LowerBody[1]
Short: ShortBubble AND PivotHigh(high, pivot left bars, pivot right bars) is defined
Short: EMA(close, shorter lookback, T1, bar still forming) < EMA(close, middle lookback, T1, bar still forming) AND EMA(close, middle lookback, T1, bar still forming) < EMA(close, longer lookback, T1, bar still forming)
Short: EMA(close, shorter lookback, T2, bar still forming) < EMA(close, middle lookback, T2, bar still forming) AND EMA(close, middle lookback, T2, bar still forming) < EMA(close, longer lookback, T2, bar still forming)
Exit: Short, high >= ShortStop at entry bar OR low <= entry price - reward-to-risk ratio * (ShortStop at entry bar - entry price)