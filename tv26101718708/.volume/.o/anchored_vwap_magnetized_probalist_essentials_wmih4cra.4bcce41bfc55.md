Calculation: Anchored VWAP = cumulative (typical price × volume) / cumulative volume, resetting at the selected session, week, month, or custom-date anchor
Calculation: Anchored standard deviation = square root of (cumulative (volume × typical price²) / cumulative volume − anchored VWAP²), with accumulators reset at the anchor
Calculation: Outer deviation bands = anchored VWAP ± outer-band multiplier × anchored standard deviation
Long: confirmed close < lower outer deviation band
Short: confirmed close > upper outer deviation band