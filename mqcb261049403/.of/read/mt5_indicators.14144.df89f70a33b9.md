Calculation: Raw movement = ((high + low) / 2 - (previous high + previous low) / 2) * ((high + low) / 2) / (2 * volume); use 0 when volume is 0.
Calculation: Main line = moving average of raw movement, using a selectable smoothing method.
Calculation: Signal line = moving average of the main line, using a separately selectable smoothing method and lookback.
Long: (main line > 0 AND main line != previous main line) OR main line > signal line
Short: (main line < 0 AND main line != previous main line) OR main line < signal line