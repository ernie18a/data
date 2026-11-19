Calculation: Structure bias = +1 if the latest confirmed PivotHigh(high, pivot lookback, pivot lookback) on T1 bars > its preceding confirmed pivot high and the latest confirmed PivotLow(low, pivot lookback, pivot lookback) on T1 bars > its preceding confirmed pivot low; -1 if both latest pivots <= their preceding pivots; otherwise 0
Calculation: Combined score = (last completed T1 close > last completed T1 open ? +1 : last completed T1 close < last completed T1 open ? -1 : 0) + Structure bias + (chart-bar close > current forming T1 open ? +1 : chart-bar close < current forming T1 open ? -1 : 0)
Long: Last completed T1 close > last completed T1 open
Short: Last completed T1 close < last completed T1 open
Long: Structure bias > 0
Short: Structure bias < 0
Long: Chart-bar close > current forming T1 open
Short: Chart-bar close < current forming T1 open
Long: Combined score >= 2
Short: Combined score <= -2