Calculation: T1 structure bias = bullish when the latest reported pivothigh(high, T1 pivot strength, T1 pivot strength) on T1 bars exceeds the preceding pivot high AND the latest reported pivotlow(low, T1 pivot strength, T1 pivot strength) exceeds the preceding pivot low; bearish when both latest pivots are less than or equal to their preceding pivots; otherwise neutral. Calculate on T1 bars with lookahead off, using the current T1 bar while it is forming.
Calculation: Chart structure bias = bullish when the latest reported pivothigh(high, chart pivot strength, chart pivot strength) on chart bars exceeds the preceding pivot high AND the latest reported pivotlow(low, chart pivot strength, chart pivot strength) exceeds the preceding pivot low; bearish when both latest pivots are less than or equal to their preceding pivots; otherwise neutral.
Calculation: Chart midpoint = (latest chart pivot high + latest chart pivot low) / 2, using chart pivots calculated with chart pivot strength for both left and right lookback.
Long: Previous completed T1 close > open
Short: Previous completed T1 close < open
Long: T1 structure bias is bullish
Short: T1 structure bias is bearish
Long: Chart close > current T1 open, using the current T1 bar while it is forming on chart bars
Short: Chart close < current T1 open, using the current T1 bar while it is forming on chart bars
Long: At least two of (previous completed T1 close > open, T1 structure bias is bullish, chart close > current T1 open) AND none of (previous completed T1 close < open, T1 structure bias is bearish, chart close < current T1 open)
Short: At least two of (previous completed T1 close < open, T1 structure bias is bearish, chart close < current T1 open) AND none of (previous completed T1 close > open, T1 structure bias is bullish, chart close > current T1 open)
Long: Selected method is the previous-candle method AND previous completed T1 close > open OR selected method is the structure method AND T1 structure bias is bullish OR selected method is the opening-range method AND chart close > current T1 open OR selected method is the combined method AND at least two of (previous completed T1 close > open, T1 structure bias is bullish, chart close > current T1 open) AND none of (previous completed T1 close < open, T1 structure bias is bearish, chart close < current T1 open)
Short: Selected method is the previous-candle method AND previous completed T1 close < open OR selected method is the structure method AND T1 structure bias is bearish OR selected method is the opening-range method AND chart close < current T1 open OR selected method is the combined method AND at least two of (previous completed T1 close < open, T1 structure bias is bearish, chart close < current T1 open) AND none of (previous completed T1 close > open, T1 structure bias is bullish, chart close > current T1 open)
Long: Chart structure bias is bullish
Short: Chart structure bias is bearish
Long: Chart close < chart midpoint
Short: Chart close > chart midpoint