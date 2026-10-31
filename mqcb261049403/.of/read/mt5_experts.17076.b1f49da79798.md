Calculation: Weighted oscillator = smooth the weighted average of RSI, money flow index, Williams %R plus 100, and DeMarker multiplied by 100; divide the weighted sum by the sum of the weights. Use volume for the money flow index. The smoothing method, its parameters, and each component's lookback and weight are configurable. Calculate on a configurable timeframe, which may be higher, lower, or equal to the chart timeframe; use a configurable signal-bar offset, including either the still-forming bar or a completed bar, and the immediately preceding bar.
Long: oscillator > midpoint
Short: oscillator < midpoint
Long: direct mode = enabled AND previous oscillator <= lower threshold AND oscillator > lower threshold
Short: direct mode = enabled AND previous oscillator >= upper threshold AND oscillator < upper threshold
Long: reverse mode = enabled AND previous oscillator >= upper threshold AND oscillator < upper threshold
Short: reverse mode = enabled AND previous oscillator <= lower threshold AND oscillator > lower threshold
Exit: long, direct mode = enabled AND previous oscillator >= upper threshold AND oscillator < upper threshold
Exit: short, direct mode = enabled AND previous oscillator <= lower threshold AND oscillator > lower threshold
Exit: long, reverse mode = enabled AND previous oscillator <= lower threshold AND oscillator > lower threshold
Exit: short, reverse mode = enabled AND previous oscillator >= upper threshold AND oscillator < upper threshold
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance