Calculation: Volume-weighted RSI histogram H = moving average of ((RSI of a selectable OHLC-derived price) − 50) × volume. Apply the same selectable smoothing method and length to volume to obtain V. The smoothing method may be SMA, EMA, SMMA, LWMA, Jurik moving average, JurX, parabolic moving average, T3, VIDYA, or Kaufman adaptive moving average.
Calculation: JurX = three successive stages of 1.5 × EMA(input) − 0.5 × EMA(EMA(input)), with each EMA using smoothing factor 3 / (length + 2) and initialized to the first input.
Calculation: Parabolic moving average = the fitted value at the newest bar from a quadratic least-squares regression over the lookback window.
Calculation: Histogram state S = 0 if H > upper outer threshold × V; otherwise 1 if H > upper inner threshold × V; otherwise 4 if H < lower outer threshold × V; otherwise 3 if H < lower inner threshold × V; otherwise 2. The upper outer threshold is greater than the upper inner threshold, and the lower outer threshold is less than the lower inner threshold.
Calculation: Histogram direction D = 1 if H > previous H; −1 if H < previous H; otherwise previous D, initialized to 1.
Long: D = 1
Short: D = −1
Long: previous H ≤ 0 AND H > 0
Short: previous H ≥ 0 AND H < 0
Long: previous S > 1 AND S = 1
Long: previous S > 0 AND S = 0
Long: previous S = 3 AND S < 3
Long: previous S = 4 AND S < 4
Short: previous S < 3 AND S = 3
Short: previous S < 4 AND S = 4
Short: previous S = 1 AND S > 1
Short: previous S = 0 AND S > 0