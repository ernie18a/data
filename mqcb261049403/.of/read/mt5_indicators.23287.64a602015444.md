Calculation: Volume-weighted Fisher oscillator = 100 × moving average of (Fisher × volume), using the selected smoothing method, length, and phase. For each bar, find the highest high and lowest low over the Fisher lookback including that bar; if they are equal, increase the highest high by one price point. Let w = (selected applied price − lowest low) / (highest high − lowest low), v = w − 0.5 + 0.67 × previous v, and Fisher = 0.5 × ln(r) + 0.5 × previous Fisher, where r = (1 + v) / (1 − v), replaced by 1 if r < 0.0000001. Initialize previous v and Fisher to zero. The applied price is a selectable OHLC-derived price; volume is the data's volume field.
Calculation: Volume-scaled levels = positive upper threshold × moving average of volume and negative lower threshold × moving average of volume, using the same smoothing method, length, and phase as the oscillator.
Calculation: Timeframe selection = calculate the oscillator and levels either on the chart timeframe or on a higher timeframe using its bar still forming; previous oscillator means the previous bar of the calculation timeframe.
Long: Oscillator > previous oscillator
Short: Oscillator < previous oscillator
Long: Oscillator > upper volume-scaled level AND oscillator >= previous oscillator
Short: Oscillator < lower volume-scaled level AND oscillator <= previous oscillator
Long: Previous oscillator < 0 AND oscillator >= 0
Short: Previous oscillator > 0 AND oscillator <= 0