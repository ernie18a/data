Calculation: Midline = One of SMA, EMA, RMA, WMA, or VWMA of close, selected each bar by the lowest score; candidate score = SMA((candidate − close)², L) + penalty × SMA(change(candidate)², L), using the same lookback L for all candidates; ties follow priority EMA, SMA, WMA, RMA, VWMA
Long: close > Midline
Short: close <= Midline