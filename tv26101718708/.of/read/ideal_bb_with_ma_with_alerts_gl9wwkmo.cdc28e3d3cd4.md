Calculation: A = recursive smoothing of the Hull moving average of hl2, using the chart timeframe and the same lookback for both calculations
Calculation: B = recursive smoothing of 3 × WMA(close, L/6) − WMA(close, L/4) − WMA(close, L/2), with the result averaged by WMA over L/2 bars; L is the Hull lookback
Calculation: Recursive smoothing of x = prior smoothed value (or x on the first bar) + (x − prior smoothed value) × √(2g/10000) + prior velocity (or 0) + (x − prior smoothed value) × g/10000; g is the smoothing gain
Long: B > A AND prior-bar B < prior-bar A
Short: A > B AND prior-bar A < prior-bar B