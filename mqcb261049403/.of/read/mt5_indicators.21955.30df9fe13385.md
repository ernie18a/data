Calculation: Smoothed series = apply the same selected moving-average method and parameters independently to each input series. The available methods are SMA, EMA, SMMA, LWMA, Jurik moving average, JurX, quadratic-regression moving average, T3, VIDYA, and Kaufman adaptive moving average.
Calculation: JurX = apply three successive stages to the input, each stage calculating two successive EMAs with smoothing coefficient 3/(length+2) and returning 1.5 times the first EMA minus 0.5 times the second; initialize each EMA with the first input.
Calculation: Quadratic-regression moving average = fit a quadratic by least squares to the input over the lookback, with observations ordered oldest to newest, and evaluate it at the newest observation.
Calculation: T3 = b-dependent linear combination of the third through sixth successive EMAs of the input, each with EMA length 1 + (smoothing length - 1)/2: -b³ times the sixth + 3(b²+b³) times the fifth - 3(2b²+b+b³) times the fourth + (1+3b+3b²+b³) times the third, where b is the curvature parameter.
Calculation: Oscillator close = smoothed series of (RSI of close - 50) multiplied by volume.
Calculation: Oscillator open = smoothed series of (RSI of open - 50) multiplied by volume, except when absolute value of chart open minus chart close is at most the gap threshold, use the previous bar's oscillator close.
Long: Oscillator close >= oscillator open
Short: Oscillator close < oscillator open
Long: Previous oscillator close < 0 AND oscillator close >= 0
Short: Previous oscillator close > 0 AND oscillator close <= 0