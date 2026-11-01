Calculation: Recursive price filter = for an input price series x, smoothing parameter k and price offset s, initialize F[0] = x[0] and V[0] = 0; for each subsequent bar set D = x - F[previous], V = V[previous] + D*k/100, and F = F[previous] + D*sqrt(k/100) + V + s. Calculate separate filters with the same k for open and close. For the candle-based trading decisions, use zero price offset.
Calculation: Line input price = a selectable open, high, low, close, (high+low)/2, (high+low+close)/3, (high+low+2*close)/4, (open+close)/2, (open+high+low+close)/4, or a trend-following price. The first trend-following price is high when close > open, low when close < open, and close otherwise; the second is (high+close)/2 when close > open, (low+close)/2 when close < open, and close otherwise.
Calculation: Trading candle = filtered open and filtered close calculated on a selectable timeframe that can be higher or lower than the chart timeframe; use a selectable bar offset, including either the last completed bar or the bar still forming, and its preceding bar.
Long: Trading candle filtered close > filtered open AND preceding trading candle filtered close <= filtered open
Short: Trading candle filtered close < filtered open AND preceding trading candle filtered close >= filtered open
Exit: short, trading candle filtered close > filtered open
Exit: long, trading candle filtered close < filtered open
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance
Long: Chart-timeframe filtered close > chart-timeframe filtered open
Short: Chart-timeframe filtered close < chart-timeframe filtered open
Long: Chart-timeframe line-input filter velocity > 0 in velocity mode OR chart-timeframe line-input filter >= its preceding value in trend mode
Short: Chart-timeframe line-input filter velocity <= 0 in velocity mode OR chart-timeframe line-input filter < its preceding value in trend mode