Calculation: Confirmed swing high = a high greater than the highs of the swingLen bars before and after it; becomes available after those later bars complete.
Calculation: Confirmed swing low = a low lower than the lows of the swingLen bars before and after it; becomes available after those later bars complete.
Calculation: Active swing high = the latest confirmed swing high not yet broken by a close crossing above it; clear it when that crossing occurs.
Calculation: Active swing low = the latest confirmed swing low not yet broken by a close crossing below it; clear it when that crossing occurs.
Long: low > high two bars earlier AND low - high two bars earlier >= minimum gap size
Long: close > active swing high AND previous close <= active swing high
Long: Higher-timeframe low > high two higher-timeframe bars earlier; use the higher-timeframe bar still forming
Short: high < low two bars earlier AND low two bars earlier - high >= minimum gap size
Short: close < active swing low AND previous close >= active swing low
Short: Higher-timeframe high < low two higher-timeframe bars earlier; use the higher-timeframe bar still forming