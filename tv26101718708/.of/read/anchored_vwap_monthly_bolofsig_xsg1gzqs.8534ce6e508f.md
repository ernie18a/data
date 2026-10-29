Calculation: Current-month anchored VWAP = volume-weighted average of hlc3 from the first bar of the current month through the current bar
Calculation: Prior-month anchored VWAP = volume-weighted average of hlc3 from the first bar of the prior month through the current bar
Calculation: Two-months-prior anchored VWAP = volume-weighted average of hlc3 from the first bar two months ago through the current bar
Long: two-months-prior anchored VWAP < prior-month anchored VWAP AND prior-month anchored VWAP < current-month anchored VWAP AND current-month anchored VWAP < close
Short: close < current-month anchored VWAP AND close < prior-month anchored VWAP AND close < two-months-prior anchored VWAP