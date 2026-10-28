Calculation: Oversold threshold = 15th percentile of RSI over a lookback, or a fixed oversold threshold if unavailable
Calculation: Overbought threshold = 85th percentile of RSI over the same lookback, or a fixed overbought threshold if unavailable
Long: RSI < oversold threshold AND previous-bar RSI >= previous-bar oversold threshold
Short: RSI > overbought threshold AND previous-bar RSI <= previous-bar overbought threshold