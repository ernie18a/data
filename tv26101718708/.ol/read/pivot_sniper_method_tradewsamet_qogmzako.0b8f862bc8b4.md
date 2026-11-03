Calculation: Confirmed pivot low = a bar’s low lower than the lows of the configured number of bars on both sides; available only after all right-side bars complete
Calculation: Confirmed pivot high = a bar’s high higher than the highs of the configured number of bars on both sides; available only after all right-side bars complete
Calculation: Pivot distance score = 20 × clamp(distance from pivot low to close for long, or close to pivot high for short, divided by ATR, 0, 2) / 2
Calculation: Wick score = 20 × clamp(relevant lower wick for long or upper wick for short divided by pivot bar range, 0, 1)
Calculation: Confirmation candle score = min(15 × abs(close − open) / (high − low) + 5 when close is bullish for long or bearish for short, 20); use zero body ratio for a zero-range bar
Calculation: Volume score = 20 × min(max(volume / volume SMA, 0) / 1.5, 1); use 10 when volume or its SMA is unavailable or the SMA is not positive
Calculation: Trend score = 10 for close above EMA plus 10 for rising EMA for long; 10 for close below EMA plus 10 for falling EMA for short
Calculation: Signal strength = nearest integer to min(sum of pivot distance, wick, confirmation candle, volume, and trend scores, 100)
Calculation: Initial stop = selected ATR stop, confirmed pivot level, pivot level buffered by ATR, or signal bar low for long / high for short; if not strictly below entry for long or above entry for short, use the ATR stop
Calculation: Target level = entry + (long) or − (short) [absolute entry-to-initial-stop distance × selected target R multiple]
Long: confirmed chart bar AND confirmed pivot low AND no confirmed pivot high on the same bar AND bullish bias allowed AND selected session active AND cooldown ready (bar distance from last accepted signal > configured cooldown) AND (strength filter disabled OR signal strength ≥ threshold)
Short: confirmed chart bar AND confirmed pivot high AND no confirmed pivot low on the same bar AND bearish bias allowed AND selected session active AND cooldown ready (bar distance from last accepted signal > configured cooldown) AND (strength filter disabled OR signal strength ≥ threshold)
Exit: Long, on any bar after entry, low ≤ active stop OR high ≥ TP3 OR a new eligible long or short signal occurs; if stop and target are both touched on one bar, stop takes priority
Exit: Short, on any bar after entry, high ≥ active stop OR low ≤ TP3 OR a new eligible long or short signal occurs; if stop and target are both touched on one bar, stop takes priority
Calculation: After the selected TP1 or TP2 is touched, move the active stop to entry plus the configured favorable offset for long / entry minus offset for short, effective from the next bar; when break-even is off, retain the initial stop