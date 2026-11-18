Calculation: upper series = EMA(HIGHEST(open(T1, still-forming bar), lookback), lookback), evaluated on chart bars using T1 values mapped to each chart bar
Calculation: lower series = EMA(LOWEST(open(T1, still-forming bar), lookback), lookback), evaluated on chart bars using T1 values mapped to each chart bar
Long: SMA(upper series, shorter lookback) crosses below SMA(upper series, longer lookback)
Short: SMA(lower series, shorter lookback) crosses above SMA(lower series, longer lookback)