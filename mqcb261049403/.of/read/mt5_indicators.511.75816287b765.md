Calculation: Signed volume = volume if (low + 2 × close) / 3 > previous bar's (high + low + close) / 3; negative volume if less; otherwise zero.
Calculation: Oscillator = shorter-period moving average of signed volume minus longer-period moving average of signed volume, using the same selectable smoothing method for both.
Calculation: Signal line = moving average of the oscillator, with an independently selectable smoothing method and period.
Long: oscillator > 0 AND oscillator > previous oscillator.
Long: oscillator > 0 AND oscillator < previous oscillator.
Short: oscillator < 0 AND oscillator < previous oscillator.
Short: oscillator < 0 AND oscillator > previous oscillator.
Long: oscillator > previous signal line.
Short: oscillator < previous signal line.