Calculation: UpperBand = upper Bollinger Band(applied price, lookback, deviation, moving-average method)
Calculation: LowerBand = lower Bollinger Band(applied price, lookback, deviation, moving-average method)
Long: On chart bars, applied price of the bar still forming > UpperBand
Short: On chart bars, applied price of the bar still forming < LowerBand
Long: On chart bars using the two most recent completed T1 bars, long-entry permission AND latest applied price > UpperBand AND preceding applied price <= UpperBand
Short: On chart bars using the two most recent completed T1 bars, short-entry permission AND latest applied price < LowerBand AND preceding applied price >= LowerBand
Exit: long, On chart bars using the two most recent completed T1 bars, long-exit permission AND (latest applied price >= LowerBand AND latest applied price <= UpperBand OR latest applied price < LowerBand AND (preceding applied price < LowerBand OR short-entry permission disabled))
Exit: short, On chart bars using the two most recent completed T1 bars, short-exit permission AND (latest applied price >= LowerBand AND latest applied price <= UpperBand OR latest applied price > UpperBand AND (preceding applied price > UpperBand OR long-entry permission disabled))