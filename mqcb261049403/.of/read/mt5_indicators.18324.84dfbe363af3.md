Calculation: Chart-timeframe percentage crossover channel middle = initialize to the previous bar’s close; on each bar, set it to close × (1 − p) if that value is above the previous middle, otherwise set it to close × (1 + p) if that value is below the previous middle, otherwise keep the previous middle, where p is the configurable percentage expressed as a fraction
Calculation: Chart-timeframe upper channel = middle × (1 + p), read from the value shifted forward by the configurable number of bars
Calculation: Chart-timeframe lower channel = middle × (1 − p), read from the value shifted forward by the configurable number of bars
Calculation: Higher-timeframe percentage crossover channel middle, upper, and lower = calculate by the same rules on higher-timeframe bars; use the still-forming higher-timeframe bar and map its channel values onto chart bars, applying the configurable forward shift
Long: Chart-timeframe close > chart-timeframe upper channel
Long: Chart-timeframe close > higher-timeframe upper channel
Short: Chart-timeframe close < chart-timeframe lower channel
Short: Chart-timeframe close < higher-timeframe lower channel