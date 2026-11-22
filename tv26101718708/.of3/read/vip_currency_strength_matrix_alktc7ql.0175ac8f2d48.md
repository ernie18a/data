Calculation: strength(currency) = sum across the 28 unique pairs, adding 1 when the currency is the base and pair close > selected SMA or EMA(close, lookback), or when it is the quote and pair close <= selected SMA or EMA(close, lookback); calculate the MA on T1 bars and evaluate on chart bars using current, possibly still-forming T1 values
Calculation: score(pair) = strength(base) - strength(quote)
Long: score(pair) > 0
Short: score(pair) < 0
Calculation: major-currency strength = for each currency, count 1 for each of the 28 pairs on T1 where it is the base and pair close > selected P1 moving average of pair close with length P2, or where it is the quote and pair close ≤ that moving average
Calculation: pair strength difference = traded pair base currency strength − traded pair quote currency strength
Long: pair strength difference > 0
Short: pair strength difference < 0