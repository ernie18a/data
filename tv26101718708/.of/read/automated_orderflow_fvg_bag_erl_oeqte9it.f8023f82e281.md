Calculation: Bullish gap = current low > high two chart bars earlier; its upper boundary is the current low and its lower boundary is the high two bars earlier. Retain the latest bullish gap until a new bullish gap replaces it.
Calculation: Bearish gap = current high < low two chart bars earlier; its upper boundary is the low two bars earlier and its lower boundary is the current high. Retain the latest bearish gap until a new bearish gap replaces it.
Calculation: Local bias = initially neutral; set bullish on a bullish gap, bearish on a bearish gap, bearish when a later close is below the latest bullish gap's lower boundary, and bullish when a later close is above the latest bearish gap's upper boundary. Apply these updates in that order on each bar. Gap creation and replacement occur only when chart-gap display is enabled; retained gaps remain active after failure.
Calculation: Higher-timeframe bias = initially neutral; when higher-timeframe bias is enabled, update it only on the first chart bar of a new higher-timeframe bar, using the last completed higher-timeframe bar: set bullish if its low > the high two higher-timeframe bars before it, or bearish if its high < the low two higher-timeframe bars before it. Otherwise retain the previous bias.
Calculation: Final bias = higher-timeframe bias when higher-timeframe bias is enabled and non-neutral; otherwise local bias.
Long: bullish gap AND chart-gap display is enabled
Short: bearish gap AND chart-gap display is enabled
Long: latest bullish gap exists AND current bar is later than its formation bar AND low <= its upper boundary AND close > its lower boundary AND no earlier bar has satisfied this condition since that gap formed AND respected-gap display is enabled
Short: latest bearish gap exists AND current bar is later than its formation bar AND high >= its lower boundary AND close < its upper boundary AND no earlier bar has satisfied this condition since that gap formed AND respected-gap display is enabled
Short: latest bullish gap exists AND current bar is later than its formation bar AND close < its lower boundary
Long: latest bearish gap exists AND current bar is later than its formation bar AND close > its upper boundary
Long: final bias is bullish
Short: final bias is bearish