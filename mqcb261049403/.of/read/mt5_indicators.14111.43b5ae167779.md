Calculation: Oscillator = calculate bull power as high minus EMA of close and bear power as low minus the same EMA; set x to their sum. Initialize L0, L1, L2, and L3 to zero. For each bar, update in order: L0 = (1 − smoothing coefficient) × x + smoothing coefficient × previous L0; L1 = −smoothing coefficient × current L0 + previous L0 + smoothing coefficient × previous L1; L2 = −smoothing coefficient × current L1 + previous L1 + smoothing coefficient × previous L2; L3 = −smoothing coefficient × current L2 + previous L2 + smoothing coefficient × previous L3. Let U be the sum of positive parts of L0 − L1, L1 − L2, and L2 − L3, and D be the sum of their negative parts as positive magnitudes. The oscillator is 100 × U / (U + D), or zero when U + D is zero. Calculate on the chart timeframe or on a higher timeframe. For the higher timeframe, use the bar still forming; historical display assigns its final value and decision to the first chart bar within it, optionally carrying them forward to the remaining chart bars.
Calculation: Persistent direction = initially zero; set to −1 when the previous oscillator is at or above either the lower or upper threshold and the current oscillator is below that threshold; set to +1 when the previous oscillator is at or below either threshold and the current oscillator is above that threshold; otherwise retain the previous direction. The lower threshold is below the middle threshold, which is below the upper threshold.
Long: Current oscillator > previous oscillator.
Short: Current oscillator < previous oscillator.
Long: Oscillator > middle threshold.
Short: Oscillator < middle threshold.
Long: Oscillator > upper threshold.
Short: Oscillator < lower threshold.
Long: Persistent direction > 0.
Short: Persistent direction < 0.