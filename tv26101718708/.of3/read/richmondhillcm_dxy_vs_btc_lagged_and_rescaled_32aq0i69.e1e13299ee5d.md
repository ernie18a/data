Calculation: selected DXY lag = if P1, the smallest lag from P2 through P3 with the minimum valid Correlation(DXY close shifted by that lag, BTC close, P4), or P5 if none are valid; otherwise P5
Calculation: range-normalized value(value, series) = 100 × (value - Lowest(series, P6)) / (Highest(series, P6) - Lowest(series, P6))
Calculation: projected BTC gap = (if P7, 100 - range-normalized value(DXY close, DXY close shifted by selected DXY lag), range-normalized value(DXY close, DXY close shifted by selected DXY lag)) - range-normalized value(BTC close, BTC close)
Long: projected BTC gap > 0
Short: projected BTC gap <= 0