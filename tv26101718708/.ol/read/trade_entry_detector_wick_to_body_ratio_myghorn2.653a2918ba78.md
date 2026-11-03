Calculation: Upper wick-to-body ratio = (high − max(open, close)) / abs(open − close), using the higher-timeframe bar still forming
Calculation: Lower wick-to-body ratio = (min(open, close) − low) / abs(open − close), using the higher-timeframe bar still forming
Calculation: Confirmed swing high/low = the latest higher-timeframe pivot high/low, using equal lookbacks before and after the pivot
Long: Lower wick-to-body ratio ≥ its threshold AND higher-timeframe low < higher-timeframe lower Bollinger Band AND chart high ≥ pending long entry price AND close > latest confirmed swing low
Short: Upper wick-to-body ratio ≥ its threshold AND higher-timeframe high > higher-timeframe upper Bollinger Band AND chart low ≤ pending short entry price AND close < latest confirmed swing high
Exit: Long, chart low ≤ latest confirmed swing low OR chart high ≥ higher-timeframe upper Bollinger Band
Exit: Short, chart high ≥ latest confirmed swing high OR chart low ≤ higher-timeframe lower Bollinger Band