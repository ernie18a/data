Calculation: Oscillator = 100 times the smoothed change in selected OHLC-derived price divided by the identically smoothed absolute change, clamped to [-100, 100]; undefined when the denominator is zero.
Calculation: Signal line = a separately parameterized moving average of the oscillator.
Calculation: Step line = for oscillator level x = (oscillator + 100) / 2 and step s, maintain upper and lower bands and a direction. Initialize the upper band to negative infinity, lower band to positive infinity, direction and line to zero. On each bar set direction to up if x exceeds the previous upper band, down if x is below the previous lower band, and otherwise retain it. Set the candidate upper band to x + 2s and lower band to x - 2s. In an up direction, raise the lower band to at least its previous value and set the line to lower band + s. In a down direction, lower the upper band to at most its previous value and set the line to upper band - s. If direction is zero, retain the previous line. Calculate a fast line with a smaller step and a slow line with a larger step. Apply this calculation either on the chart timeframe or on a higher timeframe using its still-forming bar; the higher-timeframe display can alternatively use a selected completed higher-timeframe bar.
Long: Fast step line > slow step line AND previous fast step line <= previous slow step line.
Short: Fast step line < slow step line AND previous fast step line >= previous slow step line.
Long: The most recent fast/slow step-line crossover was upward.
Short: The most recent fast/slow step-line crossover was downward.
Long: Oscillator != 0 AND oscillator > previous oscillator.
Short: Oscillator != 0 AND oscillator < previous oscillator.
Long: Oscillator > previous signal line.
Short: Oscillator < previous signal line.