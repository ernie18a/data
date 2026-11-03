Calculation: Smoothed price = smooth the close with a longer-lookback average, then smooth that result with a shorter-lookback average.
Calculation: Smoothed parabolic SAR = parabolic SAR applied to smoothed price, treating each bar’s smoothed price plus and minus one minimum price increment as its high and low.
Long: On the higher-timeframe bars, the last completed bar’s smoothed price >= smoothed parabolic SAR AND the preceding completed bar’s smoothed price < smoothed parabolic SAR
Short: On the higher-timeframe bars, the last completed bar’s smoothed price < smoothed parabolic SAR AND the preceding completed bar’s smoothed price >= smoothed parabolic SAR
Exit: long, the short condition is true
Exit: short, the long condition is true