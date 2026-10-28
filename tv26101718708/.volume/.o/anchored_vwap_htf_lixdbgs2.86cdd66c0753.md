Calculation: Confirmed higher-timeframe swing low = a bar whose low is the lowest within the configured pivot lookback bars before and after it; detected after those later bars complete.
Calculation: Confirmed higher-timeframe swing high = a bar whose high is the highest within the configured pivot lookback bars before and after it; detected after those later bars complete.
Long: A confirmed higher-timeframe swing low is detected AND none was detected on the preceding higher-timeframe bar.
Short: A confirmed higher-timeframe swing high is detected AND none was detected on the preceding higher-timeframe bar AND no confirmed swing low is detected on the same higher-timeframe bar.
Exit: Long, close < the active anchor's higher-timeframe swing-low price.
Exit: Short, close > the active anchor's higher-timeframe swing-high price.