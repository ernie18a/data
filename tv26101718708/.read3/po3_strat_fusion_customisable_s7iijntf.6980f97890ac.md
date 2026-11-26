Calculation: Up2(high, low) = high > high[1] AND low >= low[1]
Calculation: Down2(high, low) = low < low[1] AND high <= high[1]
Long: Up2(high, low, chart bars, current bar)
Short: Down2(high, low, chart bars, current bar)
Long: Up2(high, low, T1, last completed bar) AND T1 bar starts on current chart bar AND T1 not shorter than chart bars
Short: Down2(high, low, T1, last completed bar) AND T1 bar starts on current chart bar AND T1 not shorter than chart bars
Long: Up2(high, low, T2, bar still forming)
Short: Down2(high, low, T2, bar still forming)
Long: low > high[2] on T2 bars, bar still forming
Short: high < low[2] on T2 bars, bar still forming
Long: Up2(high, low, T3, bar still forming)
Short: Down2(high, low, T3, bar still forming)
Long: low > high[2] on T3 bars, bar still forming
Short: high < low[2] on T3 bars, bar still forming
Long: Up2(high, low, T4, bar still forming)
Short: Down2(high, low, T4, bar still forming)
Long: low > high[2] on T4 bars, bar still forming
Short: high < low[2] on T4 bars, bar still forming
Long: close >= open on T5 bars, bar still forming
Short: close < open on T5 bars, bar still forming
Long: close >= open on T6 bars, bar still forming
Short: close < open on T6 bars, bar still forming
Long: close >= open on T7 bars, bar still forming
Short: close < open on T7 bars, bar still forming
Long: close >= open on T8 bars, bar still forming
Short: close < open on T8 bars, bar still forming
Long: close >= open on T9 bars, bar still forming
Short: close < open on T9 bars, bar still forming