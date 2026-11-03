Calculation: RSI-level price for target L and RSI length N = close + X if X >= 0, otherwise close + X * (100 - L) / L, where X = (N - 1) * (D * L / (100 - L) - U), U is the EMA of max(close - previous close, 0), D is the EMA of max(previous close - close, 0), and both EMAs have length 2 * N - 1.
Calculation: First extended overbought target = overbought RSI threshold + extended-level spacing; first extended oversold target = oversold RSI threshold - extended-level spacing.
Calculation: Midpoint price slope = linear regression slope of the RSI-level price at the RSI scale midpoint over a lookback window, with time increasing from oldest to newest bar.
Long: Low <= RSI-level price for the first extended oversold target AND previous low > previous RSI-level price for that target.
Long: Midpoint price slope >= 0.
Short: High >= RSI-level price for the first extended overbought target AND previous high < previous RSI-level price for that target.
Short: Midpoint price slope <= 0.