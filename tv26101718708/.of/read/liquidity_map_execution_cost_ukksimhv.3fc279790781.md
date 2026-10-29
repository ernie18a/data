Calculation: Close-location volume imbalance = sum of volume × (2 × close − high − low) / (high − low), divided by total volume over a lookback; use zero for a zero-range bar. If volume is disabled, use the unweighted average of close-location values.
Calculation: Anchored VWAP = cumulative typical price (high + low + close) / 3 weighted by volume since the selected anchor, divided by cumulative volume; use equal weights if volume is disabled. The anchor may be a confirmed swing, session/week/month open, or highest-volume bar.
Long: Close-location volume imbalance > 0.15
Short: Close-location volume imbalance < −0.15
Long: Close ≥ Anchored VWAP AND Anchored VWAP ≥ its prior-bar value
Short: Close < Anchored VWAP AND Anchored VWAP < its prior-bar value