Calculation: Main RSI and fast RSI = RSI of the selected price source, with the fast RSI using a shorter length.
Calculation: Relative-volume-weighted RSI = sum(main RSI × weight) / sum(weight), where weight is volume / SMA(volume), or 1 when volume or its SMA is not positive; use the same lookback for the sums and volume SMA.
Calculation: Pressure composite = SMA of the weighted mean of six components: main RSI; its position in its rolling high-low range, scaled to 0–100; the z-score of its shorter EMA minus its longer EMA, scaled around 50 and clamped to 0–100; the similarly scaled and clamped z-score of its rate of change; its percentage position in an SMA ± standard-deviation-multiplier band, scaled to 0–100 and clamped; and its relative-volume-weighted average, clamped to 0–100. Use 50 for a zero-width range or band, a zero z-score for zero standard deviation, and main RSI when the volume-weight denominator is unavailable or zero. Use independently adjustable lookbacks, scales, band multiplier and component weights.
Calculation: Smoothed pressure = EMA of the pressure composite.
Calculation: Bull trail and bear trail = EMA of (high + low + close) / 3 minus and plus, respectively, ATR × (base multiplier + strength multiplier × absolute value of clamp((smoothed pressure − 50) / 50, −1, 1)). Trail tolerance = ATR × tolerance multiplier.
Calculation: RSI pivot = a peak or dip confirmed by the imported oscillator-pivot library using a minimum RSI swing size. The library implementation is absent from READ, so its exact confirmation and tie-handling rules cannot be reproduced from READ alone.
Long: Main RSI OR fast RSI > upper neutral threshold.
Short: Main RSI OR fast RSI < lower neutral threshold.
Long: Main RSI >= upper envelope threshold.
Short: Main RSI <= lower envelope threshold.
Long: Relative-volume-weighted RSI >= its previous-bar value.
Short: Relative-volume-weighted RSI < its previous-bar value.
Long: The shorter moving average of main RSI is above the longer moving average, OR the two are equal and their most recent crossover was upward; initialize the state as long when the averages first become valid and are equal. Apply independently to the adaptive and slower moving-average pairs, each using selectable SMA or EMA.
Short: The shorter moving average of main RSI is below the longer moving average, OR the two are equal and their most recent crossover was downward. Apply independently to the adaptive and slower moving-average pairs, each using selectable SMA or EMA.
Long: The shorter moving average of the pressure composite is above the longer moving average, OR the two are equal and their most recent crossover was upward; initialize the state as long when the averages first become valid and are equal. Each average uses selectable SMA or EMA.
Short: The shorter moving average of the pressure composite is below the longer moving average, OR the two are equal and their most recent crossover was downward.
Long: Smoothed pressure >= upper regime threshold AND close >= bull trail − trail tolerance.
Short: Smoothed pressure >= upper regime threshold AND close < bull trail − trail tolerance.
Short: Smoothed pressure <= lower regime threshold AND close <= bear trail + trail tolerance.
Long: Smoothed pressure <= lower regime threshold AND close > bear trail + trail tolerance.
Long: A new RSI pivot dip is confirmed AND the price low at that pivot is lower than at the previous confirmed RSI pivot dip AND its RSI is higher than at the previous dip.
Long: A new RSI pivot dip is confirmed AND the price low at that pivot is higher than at the previous confirmed RSI pivot dip AND its RSI is lower than at the previous dip.
Short: A new RSI pivot peak is confirmed AND the price high at that pivot is higher than at the previous confirmed RSI pivot peak AND its RSI is lower than at the previous peak.
Short: A new RSI pivot peak is confirmed AND the price high at that pivot is lower than at the previous confirmed RSI pivot peak AND its RSI is higher than at the previous peak.