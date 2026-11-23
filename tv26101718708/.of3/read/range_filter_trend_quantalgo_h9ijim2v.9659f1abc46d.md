Calculation: Smooth(x, n) = MA(x, n, smoothing type)
Calculation: Movement = abs(source - source[1])
Calculation: Range = range multiplier * Smooth(Smooth(Movement, sampling lookback), 2 * sampling lookback - 1)
Calculation: Filter = source if Range is undefined; else source - Range if source - Range > Filter[1]; else source + Range if source + Range < Filter[1]; else Filter[1]
Calculation: FlatBars = 0 if Filter != Filter[1]; else FlatBars[1] + 1
Calculation: Trend = Trend[1] if bar is not closed or Range is undefined; else 1 if Filter > Filter[1]; else -1 if Filter < Filter[1]; else 0 if neutral state enabled AND FlatBars >= neutral flat-bar threshold; else Trend[1]
Long: Trend = 1
Short: Trend = -1
Exit: long, Trend = 0
Exit: short, Trend = 0