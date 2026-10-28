Long: Total score < (close > EMA(close, long-term lookback) ? long threshold : lower-price-regime long threshold)
Short: Total score > (close > EMA(close, long-term lookback) ? higher-price-regime short threshold : short threshold)
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance OR Total score > applicable short threshold
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance OR Total score < applicable long threshold