Calculation: Daily relative strength = (close(T1, still-forming bar) - open(T1, still-forming bar)) / open(T1, still-forming bar) - (benchmark close(T1, still-forming bar) - benchmark open(T1, still-forming bar)) / benchmark open(T1, still-forming bar), evaluated on chart bars
Calculation: Short-term relative strength = ROC(close, short-term lookback) - ROC(benchmark close, same short-term lookback)
Calculation: Quarter return(source, q) = ROC(source[(q - 1) * (bars-per-year / quarter count)], q * (bars-per-year / quarter count)), reducing q by one until source[q * (bars-per-year / quarter count)] exists or q is one
Calculation: Weighted performance(source) = recent-quarter weight * Quarter return(source, first quarter) + older-quarter weight * sum of Quarter return(source, each subsequent quarter through quarter count)
Calculation: Long-term relative strength = (Weighted performance(close) - Weighted performance(benchmark close)) / Weighted performance(benchmark close)
Long: Daily relative strength is positive
Short: Daily relative strength is negative
Long: Short-term relative strength is positive
Short: Short-term relative strength is negative
Long: Long-term relative strength is positive
Short: Long-term relative strength is negative