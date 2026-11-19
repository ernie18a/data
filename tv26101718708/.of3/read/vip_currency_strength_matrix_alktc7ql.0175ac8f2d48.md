Calculation: strength(currency) = sum across the 28 unique pairs, adding 1 when the currency is the base and pair close > selected SMA or EMA(close, lookback), or when it is the quote and pair close <= selected SMA or EMA(close, lookback); calculate the MA on T1 bars and evaluate on chart bars using current, possibly still-forming T1 values
Calculation: score(pair) = strength(base) - strength(quote)
Long: score(pair) > 0
Short: score(pair) < 0