Calculation: Fractal dimension = 1 + (ln(path length) + ln 2) / ln(2 × (lookback − 1)), where path length is the sum over consecutive samples in the lookback of sqrt((difference between their prices normalized to the lookback low-high range)^2 + 1/lookback^2)
Calculation: Adaptive period = round(normal speed / (2 × (2 − fractal dimension)))
Calculation: Fractal RSI = RSI over the adaptive period, using the arithmetic means of positive and absolute negative changes in its applied-price series
Calculation: Fractal MFI = 100 − 100/(1 + positive flow/negative flow), where each flow sums volume × price over adaptive-period price increases or decreases; use the volume of the bar before each compared prior-price bar
Calculation: Fractal Williams %R = −100 × (highest high over the adaptive period − applied price) / (highest high − lowest low)
Calculation: Fractal DeMarker = average upward high changes / (average upward high changes + average downward low changes) over the adaptive period
Calculation: Smoothed weighted oscillator = smooth the weighted average of Fractal RSI, Fractal MFI, Fractal Williams %R + 100, and 100 × Fractal DeMarker
Long: smoothed weighted oscillator > 50
Short: smoothed weighted oscillator < 50