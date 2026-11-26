Calculation: MovAvg(type, src, len) = SMA(src, len) if type is SMA; EMA(src, len) if type is EMA; WMA(src, len) if type is WMA; RMA(src, len) if type is RMA; VWMA(src, len) if type is VWMA
Long: MovAvg(type1, close, shorter lookback, T1, last completed bar) > MovAvg(type2, close, longer lookback, T2, last completed bar)
Short: MovAvg(type1, close, shorter lookback, T1, last completed bar) <= MovAvg(type2, close, longer lookback, T2, last completed bar)
Long: close(T3, forming bar) > open(T3, forming bar)
Short: close(T3, forming bar) < open(T3, forming bar)