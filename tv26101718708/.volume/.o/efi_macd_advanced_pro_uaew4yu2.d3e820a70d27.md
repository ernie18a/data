Calculation: EFI = EMA(volume × (close − previous close), lookback)
Calculation: normalized MACD gap = (MACD line − MACD signal line) / ATR
Long: EFI > 0 AND (ATR filter enabled AND normalized MACD gap > threshold OR ATR filter disabled AND MACD line > MACD signal line)
Short: EFI < 0 AND (ATR filter enabled AND normalized MACD gap < −threshold OR ATR filter disabled AND MACD line < MACD signal line)
Exit: long, previous bar met the long condition AND current bar does not meet the long condition AND (EFI is falling OR the bullish MACD condition is false)
Exit: short, previous bar met the short condition AND current bar does not meet the short condition AND (EFI is rising OR the bearish MACD condition is false)