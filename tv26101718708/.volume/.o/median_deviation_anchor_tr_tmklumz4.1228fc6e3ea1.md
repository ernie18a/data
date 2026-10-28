Calculation: MDA oscillator = Apply the selected moving average to the selected source; take the selected percentile of that moving average over the median lookback as the anchor. Form upper and lower ATR bands around the anchor using the selected ATR lookback and multiplier, and upper and lower standard-deviation bands using the standard deviation of the anchor over its selected lookback. Set raw oscillator to (source − anchor) / (anchor − lower ATR band) × 100 when source is above the lower ATR band and at or above the upper standard-deviation band; otherwise set it to (source − anchor) / (upper ATR band − anchor) × 100 when source is below the upper ATR band and at or below the lower standard-deviation band; otherwise set it to zero. EMA-smooth the raw oscillator and clamp it to the selected bounds.
Calculation: Trend regime = −1 when MDA oscillator is below the short threshold, 1 when it is above the long threshold, and otherwise its previous value.
Long: MDA oscillator > long threshold
Long: MDA oscillator > 0 AND previous MDA oscillator ≤ 0
Long: Trend regime = 1 AND previous Trend regime = −1
Short: MDA oscillator < short threshold
Short: MDA oscillator < 0 AND previous MDA oscillator ≥ 0
Short: Trend regime = −1 AND previous Trend regime = 1