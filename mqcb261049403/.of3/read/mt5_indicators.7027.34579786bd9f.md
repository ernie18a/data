Calculation: Chart trend = +1 when NonLagMA(chart applied price, chart lookback, chart averaging method, chart deviation) minus its preceding chart-bar value > chart filter in points × instrument point size; −1 when the reverse difference > that threshold; otherwise retain the preceding trend
Long: Chart trend > 0
Short: Chart trend < 0
Calculation: T1 trend = +1 when NonLagMA(T1 applied price, T1 lookback, T1 averaging method, T1 deviation), calculated on T1 bars using the bar still forming, minus its preceding T1-bar value > T1 filter in points × instrument point size; −1 when the reverse difference > that threshold; otherwise retain the preceding trend; sample the matching T1-bar value onto each chart bar
Long: T1 trend sampled onto the chart bar > 0
Short: T1 trend sampled onto the chart bar < 0