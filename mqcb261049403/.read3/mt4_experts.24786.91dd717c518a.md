Calculation: RangePercent(pair) = the percentage of the still-forming T1 bar's high-low range from low to close; zero when the range is zero, sampled on chart bars
Calculation: CurrencyStrength(currency) = the rounded mean of RangePercent for each market pair containing that currency, using the value directly when it is the base currency and its complement when it is the quote currency; for NZD, include its base/JPY measure twice and omit its base/USD measure; use still-forming T1 bars, sampled on chart bars
Calculation: ChangePercent = percentage change from the previous completed T1 close to the still-forming T1 close, rounded to a separate precision parameter, sampled on chart bars
Calculation: ADR = the rounded mean of the previous completed T1 bar's range and rounded mean ranges over short, medium, and long lookbacks of completed T1 bars, where short < medium < long; sampled on chart bars
Long: chart close > PivotPoint(T1, last completed bar)
Short: chart close < PivotPoint(T1, last completed bar)
Long: chart close = high(T1, still-forming bar)
Short: chart close = low(T1, still-forming bar)
Long: RangePercent(pair) >= upper threshold
Short: RangePercent(pair) <= lower threshold
Long: ChangePercent is positive
Short: ChangePercent is negative
Long: RangePercent(pair) >= upper threshold AND either the base or quote currency's CurrencyStrength is >= the upper threshold or <= the lower threshold
Short: RangePercent(pair) <= lower threshold AND either the base or quote currency's CurrencyStrength is >= the upper threshold or <= the lower threshold
Long: ChangePercent is positive AND RangePercent(pair) >= upper threshold AND high(T1, still-forming bar) - low(T1, still-forming bar) > ADR(T1)
Short: ChangePercent is negative AND RangePercent(pair) <= lower threshold AND high(T1, still-forming bar) - low(T1, still-forming bar) > ADR(T1)