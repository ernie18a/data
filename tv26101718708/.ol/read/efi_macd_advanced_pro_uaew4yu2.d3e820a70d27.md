Calculation: EFI = EMA(volume × (close − previous close), lookback)
Calculation: normalized MACD gap = (MACD line − MACD signal line) / ATR
Long: EFI > 0 AND normalized MACD gap > threshold
Short: EFI < 0 AND normalized MACD gap < −threshold
Exit: long, previous bar had a long condition AND current bar does not have a long condition AND (EFI < previous bar’s EFI OR normalized MACD gap ≤ threshold)
Exit: short, previous bar had a short condition AND current bar does not have a short condition AND (EFI > previous bar’s EFI OR normalized MACD gap ≥ −threshold)