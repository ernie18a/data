Calculation: Order-block anchor = latest low where low is the lowest low over the order-block lookback and close > open, or latest high where high is the highest high over that lookback and close < open; otherwise retain the previous anchor, using close if none exists
Calculation: Liquidity distance = max(abs(close - order-block anchor), minimum price increment)
Calculation: Momentum = abs(close - previous close)
Calculation: Cotangent term = 1 / tan(atan(close - previous close)) when abs(tan(atan(close - previous close))) > 0.0001, otherwise 0
Calculation: Pressure = momentum * volume * (high - low) / liquidity distance²
Calculation: Projection wave = EMA(sin(pressure) + cotangent term, smoothing length)
Calculation: Projection force = projection wave * ATR * strength
Calculation: Projected cloud boundaries = close + projection force and close - projection force
Long: close > both projected cloud boundaries
Short: close < both projected cloud boundaries