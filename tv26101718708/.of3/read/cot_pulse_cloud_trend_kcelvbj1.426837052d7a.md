Calculation: Chart CFTC position(x) = CFTC position-series close on T1, or SMA(close, averaging lookback, T1 bars) when the chart timeframe is coarser than T1; map values to chart bars. Request T1 data with lookahead off: use the still-forming T1 bar in real time and the last completed T1 bar historically.
Calculation: Selected CFTC net = selected category's long position minus its short position; for Difference, non-commercial net minus commercial net.
Calculation: Smoothed CFTC value(x) = SMA(chart-mapped CFTC value(x), smoothing lookback, chart bars including the current bar); use the same smoothing parameter for long, short, and net values.
Calculation: CFTC history anchors(x) = highest, lowest, and linear-interpolation median of x over min(history lookback, available T1 bars), calculated on T1 bars with lookahead off.
Calculation: Absolute index = 100 × smoothed CFTC long position ÷ (smoothed CFTC long position + smoothed CFTC short position), or 50 if the denominator is zero.
Calculation: Relative index = 100 × (smoothed selected net − CFTC history low(selected net)) ÷ (CFTC history high(selected net) − CFTC history low(selected net)), or 50 if the high equals the low.
Long: Trend mode, or Auto mode with a non-Difference position, AND (Difference position OR NOT (smoothed CFTC long position < SMA(CFTC long position, trend-average lookback, T1 bars) AND smoothed CFTC short position < SMA(CFTC short position, trend-average lookback, T1 bars))) AND smoothed selected net >= SMA(selected net, trend-average lookback, T1 bars)
Short: Trend mode, or Auto mode with a non-Difference position, AND (Difference position OR NOT (smoothed CFTC long position < SMA(CFTC long position, trend-average lookback, T1 bars) AND smoothed CFTC short position < SMA(CFTC short position, trend-average lookback, T1 bars))) AND smoothed selected net < SMA(selected net, trend-average lookback, T1 bars)
Long: Excel mode or Difference position AND (smoothed selected net > CFTC history median(selected net) OR smoothed selected net >= 0)
Short: Excel mode or Difference position AND (smoothed selected net < CFTC history median(selected net) OR smoothed selected net < 0)
Long: Absolute mode AND non-Difference position AND Absolute index > 50
Short: Absolute mode AND non-Difference position AND Absolute index < 50
Long: Relative mode AND Relative index > 50
Short: Relative mode AND Relative index < 50
Long: Long %ile mode AND non-Difference position AND smoothed CFTC long position >= CFTC history median(CFTC long position)
Short: Long %ile mode AND non-Difference position AND smoothed CFTC long position < CFTC history median(CFTC long position)
Long: Short %ile mode AND non-Difference position AND smoothed CFTC short position < CFTC history median(CFTC short position)
Short: Short %ile mode AND non-Difference position AND smoothed CFTC short position >= CFTC history median(CFTC short position)