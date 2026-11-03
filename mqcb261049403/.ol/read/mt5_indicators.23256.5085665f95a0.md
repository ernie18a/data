Calculation: Volume-weighted Fisher oscillator = 100 × a configurable moving average of volume-weighted Fisher values, where each Fisher value is 0.5 × ln((1 + x)/(1 − x)) + 0.5 × the prior Fisher value, and x = (selected OHLC applied price’s position within the current and preceding bars’ rolling high-low range − 0.5) + 0.67 × the prior x; multiply the Fisher value by the selected volume field (volume or amount) before smoothing. Use the same moving-average method and settings to smooth the volume field separately.
Calculation: Upper and lower thresholds = the respective configurable level multiplied by the smoothed volume.
Long: Previous oscillator ≤ previous lower threshold AND current oscillator > current lower threshold
Long: Previous oscillator ≤ previous upper threshold AND current oscillator > current upper threshold
Long: Previous oscillator ≤ 0 AND current oscillator > 0
Long: Previous trigger value ≥ previous oscillator AND current trigger value < current oscillator
Long: Current oscillator > current upper threshold AND current oscillator ≥ current trigger value
Long: Current oscillator < current lower threshold AND current oscillator ≤ current trigger value
Long: Previous oscillator < 0 AND current oscillator ≥ 0
Short: Previous oscillator ≥ previous upper threshold AND current oscillator < current upper threshold
Short: Previous oscillator ≥ previous lower threshold AND current oscillator < current lower threshold
Short: Previous oscillator ≥ 0 AND current oscillator < 0
Short: Previous trigger value ≤ previous oscillator AND current trigger value > current oscillator
Short: Current oscillator < current lower threshold AND current oscillator ≤ current trigger value
Short: Current oscillator > current upper threshold AND current oscillator ≥ current trigger value
Short: Previous oscillator > 0 AND current oscillator ≤ 0