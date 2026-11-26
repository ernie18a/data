Calculation: Adaptive step direction = initialize the prior lower and upper bands to opposite extremes and the direction to neutral; on each chart bar, set x = (RSX(close, lookback) + 100) / 2 and candidate bands to x ± band multiplier × step size; set direction to long if x exceeds the prior upper band, to short if x is below the prior lower band, and otherwise retain its prior direction; when direction is long, set the lower band to max(candidate lower band, prior lower band); when direction is short, set the upper band to min(candidate upper band, prior upper band)
Long: RSX(close, lookback) > 0
Short: RSX(close, lookback) < 0
Long: Adaptive step direction with fast step size is long
Short: Adaptive step direction with fast step size is short
Long: Adaptive step direction with slow step size is long
Short: Adaptive step direction with slow step size is short