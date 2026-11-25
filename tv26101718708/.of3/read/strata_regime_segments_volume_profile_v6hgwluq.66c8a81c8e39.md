Calculation: Daily innovation sigma = square root of the EWMA of squared one-step local-linear Kalman prediction errors for source, using separate level-noise, slope-noise, and variance-memory parameters
Calculation: Segment direction = 1 when the active segment's OLS slope per bar exceeds the flat dead-zone parameter times its mean daily innovation sigma, −1 when below the negative threshold, and 0 otherwise
Long: Segment direction = 1 AND Segment direction[1] != 1
Short: Segment direction = −1 AND Segment direction[1] != −1
Exit: long, Segment direction = 0 AND Segment direction[1] != 0
Exit: short, Segment direction = 0 AND Segment direction[1] != 0