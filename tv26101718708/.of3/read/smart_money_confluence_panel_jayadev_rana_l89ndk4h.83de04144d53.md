Calculation: Latest confirmed swing high = most recently confirmed PivotHigh(high, swing lookback, swing lookback)
Calculation: Previous confirmed swing high = confirmed PivotHigh before the latest confirmed swing high
Calculation: Latest confirmed swing low = most recently confirmed PivotLow(low, swing lookback, swing lookback)
Calculation: Previous confirmed swing low = confirmed PivotLow before the latest confirmed swing low
Calculation: Strong-close body condition = high > low AND abs(close - open) >= (high - low) * strong-close percentage / 100
Long: On confirmation of a pivot high, no previous confirmed swing high exists or the current pivot high >= the previous confirmed swing high
Short: On confirmation of a pivot high, the current pivot high < the previous confirmed swing high
Long: On confirmation of a pivot low, no previous confirmed swing low exists or the current pivot low >= the previous confirmed swing low
Short: On confirmation of a pivot low, the current pivot low < the previous confirmed swing low
Long: close > latest confirmed swing high AND close[1] <= latest confirmed swing high AND (strong-close filter disabled OR strong-close body condition) AND market-bias setting permits bullish breaks
Short: close < latest confirmed swing low AND close[1] >= latest confirmed swing low AND (strong-close filter disabled OR strong-close body condition) AND market-bias setting permits bearish breaks
Long: low > high[2]
Short: high < low[2]
Long: low < latest confirmed swing low AND close > latest confirmed swing low
Short: high > latest confirmed swing high AND close < latest confirmed swing high
Long: low < latest confirmed swing low AND close > latest confirmed swing low AND market-bias setting permits bullish reversals
Short: high > latest confirmed swing high AND close < latest confirmed swing high AND market-bias setting permits bearish reversals
Long: no break of structure has occurred or the latest break of structure is bullish
Short: the latest break of structure is bearish
Long: For each scanned symbol, on chart bars, close(T1, current still-forming bar) > SMA(close, scanner lookback, T1, current still-forming bar)
Short: For each scanned symbol, on chart bars, close(T1, current still-forming bar) <= SMA(close, scanner lookback, T1, current still-forming bar)