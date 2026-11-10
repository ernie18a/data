Calculation: Bullish gap = current low > high two bars earlier; its upper boundary is the current low and its lower boundary is the high two bars earlier. Retain the latest bullish gap until replaced by a new bullish gap, even if it fails.
Calculation: Bearish gap = current high < low two bars earlier; its upper boundary is the low two bars earlier and its lower boundary is the current high. Retain the latest bearish gap until replaced by a new bearish gap, even if it fails.
Calculation: Chart bias = initially neutral; set bullish on a new bullish gap and bearish on a new bearish gap. After updating gaps, set bearish if a later bar closes below the latest bullish gap's lower boundary; then set bullish if a later bar closes above the latest bearish gap's upper boundary.
Calculation: Higher-timeframe bias = initially neutral; on the first chart bar of a new higher-timeframe bar, set bullish if the last completed higher-timeframe bar forms a bullish gap, or bearish if it forms a bearish gap. Otherwise retain the previous bias.
Calculation: Final bias = higher-timeframe bias when non-neutral; otherwise chart bias.
Long: Current low > high two bars earlier.
Long: Current bar is later than the latest bullish gap AND low <= its upper boundary AND close > its lower boundary AND no previous bar has satisfied these conditions for that gap.
Long: Current bar is later than the latest bearish gap AND close > its upper boundary.
Long: First chart bar of a new higher-timeframe bar AND the last completed higher-timeframe bar's low > the high two higher-timeframe bars before it.
Long: Final bias = bullish.
Short: Current high < low two bars earlier.
Short: Current bar is later than the latest bearish gap AND high >= its lower boundary AND close < its upper boundary AND no previous bar has satisfied these conditions for that gap.
Short: Current bar is later than the latest bullish gap AND close < its lower boundary.
Short: First chart bar of a new higher-timeframe bar AND the last completed higher-timeframe bar's high < the low two higher-timeframe bars before it.
Short: Final bias = bearish.