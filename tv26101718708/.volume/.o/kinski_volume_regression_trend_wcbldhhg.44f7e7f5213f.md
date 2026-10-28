Calculation: Smoothed regression slope = linear regression of the selected price source over a configurable lookback, evaluated at offsets 0 and 1 and subtracted (offset 1 from offset 0), optionally smoothed by a configurable moving average
Calculation: Oscillator = smoothed regression slope × its lookback
Calculation: Regular bullish divergence = a confirmed oscillator pivot low is higher than the previous oscillator pivot low AND its corresponding price low is lower than the previous price pivot low AND the previous pivot is within the configured minimum and maximum separation
Calculation: Regular bearish divergence = a confirmed oscillator pivot high is lower than the previous oscillator pivot high AND its corresponding price high is higher than the previous price pivot high AND the previous pivot is within the configured minimum and maximum separation
Long: smoothed regression slope > 0 OR regular bullish divergence
Short: smoothed regression slope < 0 OR regular bearish divergence