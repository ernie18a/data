Calculation: Smoothed LRMA vote score = MA(method 2, 100/count × Σ[i=0..count−1](+1 if LRMA(applied price, LRMA lookback) > MA(method 1, LRMA(applied price, LRMA lookback), starting length + i × length step, phase 1), otherwise −1), second smoothing length, phase 2) (per indicator bar; the EAs read it on T1 at the configured signal offset, which may select a completed or still-forming bar)
Long: Smoothed LRMA vote score > 0
Short: Smoothed LRMA vote score < 0
Long: On T1 bars, smoothed LRMA vote score at the signal offset crosses above the upper threshold
Long: On T1 bars, smoothed LRMA vote score at the signal offset crosses above the upper threshold AND ChangeOfVolatility(momentum lookback, short lookback, long lookback, upper threshold, trend threshold) at that offset on T1 bars > trend threshold
Short: On T1 bars, smoothed LRMA vote score at the signal offset crosses below the lower threshold
Short: On T1 bars, smoothed LRMA vote score at the signal offset crosses below the lower threshold AND ChangeOfVolatility(momentum lookback, short lookback, long lookback, upper threshold, trend threshold) at that offset on T1 bars > trend threshold
Long: On T1 bars, smoothed LRMA vote score at the signal offset > its preceding value AND its preceding value < the value before that
Long: On T1 bars, smoothed LRMA vote score at the signal offset > its preceding value AND its preceding value < the value before that AND ChangeOfVolatility(momentum lookback, short lookback, long lookback, upper threshold, trend threshold) at that offset on T1 bars > trend threshold
Short: On T1 bars, smoothed LRMA vote score at the signal offset < its preceding value AND its preceding value > the value before that
Short: On T1 bars, smoothed LRMA vote score at the signal offset < its preceding value AND its preceding value > the value before that AND ChangeOfVolatility(momentum lookback, short lookback, long lookback, upper threshold, trend threshold) at that offset on T1 bars > trend threshold
Exit: long, smoothed LRMA vote score at the signal offset on T1 bars < the lower threshold
Exit: short, smoothed LRMA vote score at the signal offset on T1 bars > the upper threshold
Exit: long, smoothed LRMA vote score at the signal offset on T1 bars < its preceding value
Exit: short, smoothed LRMA vote score at the signal offset on T1 bars > its preceding value