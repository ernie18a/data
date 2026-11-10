Calculation: Delta = volume × (2 × close − high − low) / (high − low) when high > low; otherwise 0.
Calculation: Delta ratio = delta / volume when volume > 0; otherwise 0.
Calculation: Cumulative delta = running sum of delta, starting at 0; in session reset mode, reset to the current delta when the day of week changes or the bar timestamp reaches the configured reset time. In the other reset modes, do not reset.
Calculation: Smoothed delta Z-score = EMA of (delta − rolling mean of delta) / rolling standard deviation of delta; use 0 when the standard deviation is 0.
Calculation: Confirmed pivot low = a low with no lower low among an equal number of preceding bars and no equal or lower low among that number of subsequent bars; confirm on the final subsequent bar. A pivot high reverses these comparisons. Use the same number of bars on each side and for both pivot types.
Long: Delta ratio > positive imbalance threshold.
Short: Delta ratio < negative imbalance threshold of the same magnitude.
Long: Delta ratio > positive bias threshold.
Short: Delta ratio < negative bias threshold of the same magnitude.
Long: Delta >= 0.
Short: Delta < 0.
Long: Cumulative delta >= 0.
Short: Cumulative delta < 0.
Long: Smoothed delta Z-score >= 0.
Short: Smoothed delta Z-score < 0.
Long: Smoothed delta Z-score crosses above a positive surge threshold.
Short: Smoothed delta Z-score crosses below a negative surge threshold of the same magnitude.
Long: A pivot low is confirmed AND its low < the preceding confirmed pivot low AND cumulative delta at the current pivot > cumulative delta at the preceding pivot low.
Short: A pivot high is confirmed AND its high > the preceding confirmed pivot high AND cumulative delta at the current pivot < cumulative delta at the preceding pivot high.