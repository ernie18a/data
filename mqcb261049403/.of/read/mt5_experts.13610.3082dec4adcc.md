Calculation: Volume oscillator = for each bar, let U = (volume + (close - open) / price point size) / 2 and D = volume - U. Smooth U and D separately twice, using the same smoothing method and the same respective first-stage and second-stage lengths for both. Let R = 100 * (smoothed U - smoothed D) / (smoothed U + smoothed D), or 0 if the denominator is 0. Smooth R once, then smooth the result twice more in sequence to obtain E. Subtract a further smoothing of E from E, then smooth that difference to obtain the oscillator. Use the same smoothing method throughout, with independently configurable stage lengths.
Calculation: Higher-timeframe oscillator values H0, H1, H2 = the volume oscillator on the last completed higher-timeframe bar and the two preceding higher-timeframe bars, respectively.
Long: H0 > H1 AND H1 <= H2
Short: H0 < H1 AND H1 >= H2
Long: chart-timeframe volume oscillator > 0 AND chart-timeframe volume oscillator != its previous-bar value
Short: chart-timeframe volume oscillator < 0 AND chart-timeframe volume oscillator != its previous-bar value
Exit: long, H0 < H1
Exit: short, H0 > H1
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance