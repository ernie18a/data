Calculation: Swing low = a low lower than the lows of an equal number of bars before and after it; signal when the after-bars are complete
Calculation: Swing high = a high higher than the highs of an equal number of bars before and after it; signal when the after-bars are complete
Calculation: Pivot-window volume delta = sum, over the bars from the swing-length bars before the pivot through the swing-length bars after it, of volume × (2 × (close − low) / (high − low) − 1); if high = low, use volume when close ≥ open and −volume otherwise
Calculation: Delta strength = 100 × abs(pivot-window volume delta) / max(abs(current pivot-window volume delta), abs(delta stored for each active level), 0.0001); active levels exclude levels broken by the current close and retain only the newest configured number
Long: confirmed swing low AND delta strength ≥ minimum delta percentage
Short: confirmed swing high AND delta strength ≥ minimum delta percentage