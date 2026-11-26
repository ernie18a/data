Calculation: OsMA = (EMA((high + low + 2 × close) / 4, shorter lookback) - EMA((high + low + 2 × close) / 4, longer lookback)) - EMA(EMA((high + low + 2 × close) / 4, shorter lookback) - EMA((high + low + 2 × close) / 4, longer lookback), signal lookback)
Long: OsMA >= OsMA[1]
Short: OsMA <= OsMA[1]
Long: OsMA(T1, still-forming bar) >= OsMA(previous T1 bar), using T1 values sampled on chart bars
Short: OsMA(T1, still-forming bar) <= OsMA(previous T1 bar), using T1 values sampled on chart bars