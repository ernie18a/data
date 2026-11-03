Calculation: Trend line = On the configured indicator timeframe, highest high minus (highest high minus lowest low) × a percentage parameter, using the current bar and the preceding bars in a lookback.
Calculation: Signal line = Trend line from a specified number of bars earlier on the configured indicator timeframe.
Long: On the last completed indicator bar, Trend line > Signal line AND on the preceding completed indicator bar, Trend line <= Signal line
Short: On the last completed indicator bar, Trend line < Signal line AND on the preceding completed indicator bar, Trend line >= Signal line
Exit: long, Trend line < Signal line on the last completed indicator bar
Exit: short, Trend line > Signal line on the last completed indicator bar