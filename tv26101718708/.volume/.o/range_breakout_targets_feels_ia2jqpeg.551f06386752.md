Calculation: Normalized range = (highest high − lowest low over the tightness lookback) / current close; evaluate on each completed chart bar.
Calculation: Quiet threshold = nearest-rank percentile of Normalized range over the comparison lookback; a bar is quiet when Normalized range ≤ Quiet threshold.
Calculation: Active range box = highest high and lowest low from the start of a consecutive quiet run through its end, where the run starts lookback−1 bars before its first quiet bar and is kept only if it lasts at least the minimum duration. Keep the box active while closes remain inside it; widen it with any later qualifying quiet run overlapping it. Remove it if not broken within the maximum wait.
Calculation: Breakout target = broken box edge + (box height × target multiplier) for an upward break, or broken box edge − (box height × target multiplier) for a downward break.
Long: an active range box exists AND close > its high
Short: an active range box exists AND close < its low
Exit: long, high ≥ its upward-breakout target OR close < the broken box's opposite edge
Exit: short, low ≤ its downward-breakout target OR close > the broken box's opposite edge