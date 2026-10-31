Calculation: Oscillator = 200 × triple-smoothed (selected price − rolling lowest low) / triple-smoothed (rolling highest high − rolling lowest low) − 100; use the same selected smoothing method and corresponding first, second, and third smoothing lengths for numerator and denominator; return 0 when the smoothed denominator is 0.
Calculation: Signal = selected moving average of the oscillator, using the same length as the oscillator's third smoothing stage.
Calculation: Higher-timeframe trend = at the first chart bar of each higher-timeframe bar, compare the oscillator on the still-forming higher-timeframe bar with its immediately preceding completed bar; retain the latest nonzero comparison until the next nonzero comparison.
Long: Oscillator > Signal AND Oscillator != 0 AND Signal != 0
Short: Oscillator < Signal AND Oscillator != 0 AND Signal != 0
Long: Oscillator > previous-bar oscillator AND Oscillator != 0
Short: Oscillator < previous-bar oscillator AND Oscillator != 0
Long: Higher-timeframe trend > 0
Short: Higher-timeframe trend < 0