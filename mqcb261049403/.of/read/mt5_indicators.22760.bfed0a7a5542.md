Calculation: Oscillator = Jurik moving average, with maximum phase, of volume × (100 × (selected price − (price moving average − range moving average)) / (2 × range moving average) − 50), where range is high − low, the price and range moving averages have independently selected methods and lengths, and a zero range moving average is replaced by 1 only in the denominator.
Calculation: Volume baseline = Jurik moving average of volume with the same length and maximum phase as the oscillator smoothing.
Calculation: Direction = the sign of the most recent nonzero change in the oscillator from one bar to the next; retain that sign when the oscillator is unchanged.
Calculation: Higher-timeframe oscillator and volume baseline = the same calculations on a higher timeframe using its still-forming bar at the start of each chart bar, held at the value copied on the first chart bar of that higher-timeframe bar.
Long: Oscillator > upper threshold × volume baseline OR direction > 0.
Short: Oscillator < lower threshold × volume baseline OR direction < 0.
Long: Higher-timeframe oscillator > upper threshold × higher-timeframe volume baseline OR higher-timeframe direction > 0.
Short: Higher-timeframe oscillator < lower threshold × higher-timeframe volume baseline OR higher-timeframe direction < 0.