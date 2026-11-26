Calculation: short-to-long average ratio = SMA(close, shorter lookback) / SMA(close, longer lookback)
Calculation: close-to-average ratio = close / SMA(close, average lookback)
Calculation: rolling close low = lowest(close, price lookback)
Calculation: rolling close high = highest(close, price lookback)
Calculation: prior minimum volume = lowest(volume[1], volume lookback)
Long: short-to-long average ratio > upper trend threshold
Short: short-to-long average ratio < lower trend threshold
Long: close-to-average ratio > upper displayed distance threshold
Short: close-to-average ratio < lower displayed distance threshold
Long: short-to-long average ratio > upper trend threshold AND round(close-to-average ratio, rounding precision) > alert distance threshold AND ((close / rolling close low >= upward ratio threshold OR close - rolling close low >= upward amount threshold) AND close >= long minimum price AND prior minimum volume >= minimum volume threshold)
Long: (close / rolling close low >= upward ratio threshold OR close - rolling close low >= upward amount threshold) AND close >= long minimum price AND prior minimum volume >= minimum volume threshold
Short: (close / rolling close high <= downward ratio threshold OR rolling close high - close >= downward amount threshold) AND close >= short minimum price AND prior minimum volume >= minimum volume threshold AND NOT ((close / rolling close low >= upward ratio threshold OR close - rolling close low >= upward amount threshold) AND close >= long minimum price)