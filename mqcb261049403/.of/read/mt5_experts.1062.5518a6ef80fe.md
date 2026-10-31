Calculation: Double-smoothed moving average = apply a selected moving-average method to a selected bar price, then apply a second independently parameterized moving-average method to the result. Calculate on the selected indicator timeframe, which may be higher or lower than the chart timeframe; use the last completed indicator bar or, if configured, the forming indicator bar. Let A, B, and C be its values on the selected bar and the two preceding indicator bars, respectively.
Long: A > B AND B < C
Short: A < B AND B > C
Exit: long, A < B OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, A > B OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance