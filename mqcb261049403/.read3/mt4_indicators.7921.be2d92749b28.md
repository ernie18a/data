Calculation: Reference level = current-session open if open mode is selected; otherwise (prior-session high + prior-session low + prior-session close) / 3
Long: Ask > Reference level + offset 1 - tolerance AND Ask < Reference level + offset 1 + tolerance
Long: Ask > Reference level + offset 2 - tolerance AND Ask < Reference level + offset 2 + tolerance
Short: Bid < Reference level - offset 1 + tolerance AND Bid > Reference level - offset 1 - tolerance
Short: Bid < Reference level - offset 2 + tolerance AND Bid > Reference level - offset 2 - tolerance
Long: +DI(lookback) > -DI(lookback) OR Force Index(lookback) > Force Index threshold OR RSI(close, lookback) > RSI threshold
Short: +DI(lookback) < -DI(lookback) OR Force Index(lookback) < Force Index threshold OR RSI(close, lookback) < RSI threshold