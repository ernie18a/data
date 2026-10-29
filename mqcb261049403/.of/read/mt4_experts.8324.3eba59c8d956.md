Calculation: EMA spread = shorter-lookback EMA of close minus longer-lookback EMA of close, on the chart timeframe using the last completed bar
Long: EMA spread < parameterized threshold AND shorter-lookback RSI < parameterized threshold AND current chart bar volume <= parameterized threshold
Short: EMA spread > parameterized threshold AND longer-lookback RSI > parameterized threshold AND current chart bar volume <= parameterized threshold
Exit: long, low <= entry price minus parameterized stop distance OR high >= entry price plus parameterized take-profit distance
Exit: short, high >= entry price plus parameterized stop distance OR low <= entry price minus parameterized take-profit distance