Calculation: T1 bias = 1 when EMA(source, shorter lookback, T1, selected bar) > EMA(source, longer lookback, T1, selected bar), -1 when <, otherwise 0; use the same shorter and longer lookbacks on T1, T2, and T3; compute the EMAs on T1 bars and sample their values on chart bars; selected bar is the last completed T1 bar when the confirmed-values parameter is enabled, otherwise the still-forming T1 bar
Calculation: T2 bias = 1 when EMA(source, shorter lookback, T2, selected bar) > EMA(source, longer lookback, T2, selected bar), -1 when <, otherwise 0; compute the EMAs on T2 bars and sample their values on chart bars; selected bar is the last completed T2 bar when the confirmed-values parameter is enabled, otherwise the still-forming T2 bar
Calculation: T3 bias = 1 when EMA(source, shorter lookback, T3, selected bar) > EMA(source, longer lookback, T3, selected bar), -1 when <, otherwise 0; compute the EMAs on T3 bars and sample their values on chart bars; selected bar is the last completed T3 bar when the confirmed-values parameter is enabled, otherwise the still-forming T3 bar
Calculation: Bullish alignment = T1 bias = 1 AND T2 bias = 1 AND T3 bias = 1
Calculation: Bearish alignment = T1 bias = -1 AND T2 bias = -1 AND T3 bias = -1
Calculation: Alignment = Bullish alignment OR Bearish alignment
Long: T1 bias = 1
Long: T2 bias = 1
Long: T3 bias = 1
Long: Bullish alignment AND NOT Bullish alignment[1]
Short: T1 bias = -1
Short: T2 bias = -1
Short: T3 bias = -1
Short: Bearish alignment AND NOT Bearish alignment[1]
Exit: long, Alignment[1] AND NOT Alignment
Exit: short, Alignment[1] AND NOT Alignment