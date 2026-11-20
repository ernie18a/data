Calculation: Rolling price range = max(highest(high, lookback) - lowest(low, lookback), epsilon)
Calculation: Volume-profile point of control = midpoint of the highest-volume bin among bin-count equal-width bins spanning the rolling low to rolling high, with each bar's volume assigned to a price bin
Calculation: Value-area high and low = outer bounds of bins expanded from the point-of-control bin toward the adjacent bin with greater volume until the included volume reaches the value-area fraction of total volume
Calculation: Normalized oscillator = EMA(clamp((close - lowest(low, lookback)) / rolling price range * 100, 0, 100), oscillator smoothing lookback)
Calculation: Normalized point of control = clamp((volume-profile point of control - lowest(low, lookback)) / rolling price range * 100, 0, 100)
Calculation: Normalized value-area high and low = clamp((value-area high or low - lowest(low, lookback)) / rolling price range * 100, 0, 100)
Calculation: Oscillator basis = EMA(normalized oscillator, basis lookback)
Calculation: Point-of-control spread average = EMA(normalized oscillator - normalized point of control, slope lookback)
Long: normalized oscillator > normalized point of control OR normalized oscillator < normalized value-area low OR normalized oscillator < oversold level OR normalized oscillator >= oscillator basis OR point-of-control spread average >= 0
Short: normalized oscillator <= normalized point of control OR normalized oscillator > normalized value-area high OR normalized oscillator > overbought level OR normalized oscillator < oscillator basis OR point-of-control spread average < 0