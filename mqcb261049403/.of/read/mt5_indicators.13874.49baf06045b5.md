Calculation: Normalized oscillator = Clamp to [-1, 1] the ratio of the JurX-smoothed price deviation to the JurX-smoothed absolute price deviation; price deviation is the selected price minus its Jurik moving average. The two JurX smoothers use the same length. The oscillator is undefined when the denominator is zero.
Calculation: JurX smoothing = Apply three stages in sequence. For each stage, update a = (1-k) * previous a + k * input and then b = k * a + (1-k) * previous b; the stage output is 1.5 * a - 0.5 * b, where k = 3 / (length + 2). Initialize both states of each stage to its first input.
Calculation: Fast trend = Weighted sum of five normalized oscillators with progressively longer Jurik moving average lengths and a shared JurX length and Jurik phase; the second and third oscillators use the same weight.
Calculation: Slow trend = Fast trend divided by a smoothing length plus the previous slow trend multiplied by (smoothing length - 1) / smoothing length; initialize it to the first fast trend divided by the smoothing length.
Long: Chart-timeframe fast trend > chart-timeframe slow trend
Short: Chart-timeframe fast trend < chart-timeframe slow trend
Long: Higher-timeframe fast trend > higher-timeframe slow trend, using the higher-timeframe bar still forming
Short: Higher-timeframe fast trend < higher-timeframe slow trend, using the higher-timeframe bar still forming