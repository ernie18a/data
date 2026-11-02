Calculation: Factor Z-score = (factor minus its rolling SMA) divided by its rolling population standard deviation; use zero when the standard deviation is unavailable or nonpositive. Use the ROC lookback for ROC, ATR lookback for ATR, volume-flow lookback for volume flow, and longer EMA lookback for EMA difference.
Calculation: Composite = the sum-normalized weighted average of the Z-scores of close ROC, ATR, volume flow, and EMA difference. Volume flow is cumulative volume minus its EMA. EMA difference is the shorter close EMA minus the longer close EMA. If all weights are zero, the composite is zero.
Calculation: Composite slope = EMA of composite minus a separately calculated EMA of the previous-bar composite, substituting the current composite when the previous value is unavailable. Previous composite slope = that second EMA minus a separately calculated EMA of the composite two bars ago, substituting the current composite when unavailable. All three EMAs use the same length.
Calculation: Price divergence slope = (close minus close at the divergence lookback) divided by close at the divergence lookback; substitute the current close when the historical close is unavailable and use zero when the denominator is zero.
Calculation: Composite divergence slope = composite minus composite at the divergence lookback; substitute the current composite when the historical value is unavailable.
Long: Composite slope > 0.
Short: Composite slope < 0.
Long: Composite slope > 0 AND previous composite slope <= 0.
Short: Composite slope < 0 AND previous composite slope >= 0.
Long: Composite > 0.
Short: Composite < 0.
Long: Composite < the low threshold OR composite > 0 AND composite <= the high threshold.
Short: Composite > the high threshold OR composite < 0 AND composite >= the low threshold.
Long: Any factor Z-score > 0.
Short: Any factor Z-score < 0.
Long: Composite crosses above the high threshold AND more than one bar has elapsed since the preceding high-threshold event.
Short: Composite crosses below the low threshold AND more than one bar has elapsed since the preceding low-threshold event.
Long: Price divergence slope < negative divergence epsilon AND composite divergence slope > divergence epsilon AND bars since the last bullish or bearish divergence >= divergence cooldown.
Short: Price divergence slope > divergence epsilon AND composite divergence slope < negative divergence epsilon AND bars since the last bullish or bearish divergence >= divergence cooldown.