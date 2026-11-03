Calculation: Signed-volume oscillator = EMA of signed volume with a shorter lookback minus EMA of signed volume with a longer lookback; signed volume is volume when the selected price source is at least its previous value, otherwise negative volume.
Calculation: Smoothed oscillator = selected moving average of the signed-volume oscillator.
Calculation: Signal line = selected moving average of the smoothed oscillator, with independent moving-average parameters.
Calculation: Primary oscillator = either the signed-volume oscillator or the smoothed oscillator; its corresponding signal is the smoothed oscillator or the signal line, respectively.
Calculation: Oscillator pivot = a confirmed pivot high or low of the primary oscillator, using separate left and right lookbacks; evaluate it when the right lookback has elapsed.
Calculation: Divergence pivot range = the number of bars between the current and preceding confirmed oscillator pivots of the same type, plus one.
Long: Primary oscillator crosses above its corresponding signal.
Short: Primary oscillator crosses below its corresponding signal.
Long: A confirmed oscillator pivot low is higher than the preceding oscillator pivot low AND the price low at that pivot is lower than the price low at the preceding oscillator pivot low AND the divergence pivot range is within the inclusive configured range.
Long: A confirmed oscillator pivot low is lower than the preceding oscillator pivot low AND the price low at that pivot is higher than the price low at the preceding oscillator pivot low AND the divergence pivot range is within the inclusive configured range.
Short: A confirmed oscillator pivot high is lower than the preceding oscillator pivot high AND the price high at that pivot is higher than the price high at the preceding oscillator pivot high AND the divergence pivot range is within the inclusive configured range.
Short: A confirmed oscillator pivot high is higher than the preceding oscillator pivot high AND the price high at that pivot is lower than the price high at the preceding oscillator pivot high AND the divergence pivot range is within the inclusive configured range.
Long: Primary oscillator on the selected reference timeframe is greater than zero.
Short: Primary oscillator on the selected reference timeframe is less than zero.
Long: Primary oscillator on the selected reference timeframe is greater than zero AND greater than its corresponding signal.
Short: Primary oscillator on the selected reference timeframe is less than zero AND less than its corresponding signal.
Long: Primary oscillator on the selected reference timeframe is greater than zero AND greater than the selected band or channel basis.
Short: Primary oscillator on the selected reference timeframe is less than zero AND less than the selected band or channel basis.
Long: Primary oscillator on the selected reference timeframe is greater than zero AND greater than the selected band or channel's inner lower boundary.
Short: Primary oscillator on the selected reference timeframe is less than zero AND less than the selected band or channel's inner upper boundary.
Long: Signal line on the selected reference timeframe is greater than its previous value.
Short: Signal line on the selected reference timeframe is less than or equal to its previous value.
Long: Smoothed oscillator on the selected reference timeframe is greater than its previous value.
Short: Smoothed oscillator on the selected reference timeframe is less than or equal to its previous value.
Long: Smoothed oscillator is greater than the signal line.
Short: Smoothed oscillator is less than or equal to the signal line.