Calculation: Confirmed pivot = a high or low with the same number of bars on each side; the pivot is confirmed on the last right-hand bar. For equal extrema, the most recent bar is the pivot. Use a longer lookback for swing pivots and a shorter lookback for internal pivots.
Calculation: Unbroken pivot = the latest confirmed pivot of its type and layer, until the selected break price first exceeds a high pivot or falls below a low pivot; a newly confirmed pivot replaces the previous pivot and resets its broken status. Select close for both break prices, or high for upward breaks and low for downward breaks.
Calculation: Swing range = the latest confirmed swing high and low; on an upward swing break, reset the range low to the latest swing low if available; on a downward swing break, reset the range high to the latest swing high if available. Process upward breaks before downward breaks.
Calculation: Equilibrium boundaries = the swing-range midpoint plus and minus a configurable fraction of the swing-range width.
Calculation: Entry risk = at entry, choose the latest swing low for a long or swing high for a short, falling back to the corresponding internal pivot if the swing pivot is unavailable. Optionally place a raw stop beyond that pivot by an ATR buffer; if the stop is unavailable or is not below entry for a long or above entry for a short, use an ATR-multiple distance from entry instead. Clamp the absolute entry-to-stop distance between configurable minimum and maximum ATR multiples, using entry-bar ATR, and retain it for the position.
Long: A swing low pivot is confirmed.
Long: The selected upward break price > an unbroken swing high pivot OR the selected upward break price > an unbroken internal high pivot.
Long: Swing range high > swing range low AND close < lower equilibrium boundary.
Short: A swing high pivot is confirmed.
Short: The selected downward break price < an unbroken swing low pivot OR the selected downward break price < an unbroken internal low pivot.
Short: Swing range high > swing range low AND close > upper equilibrium boundary.
Exit: long, a bar after entry has low <= entry price - entry risk OR high >= entry price + entry risk * reward-to-risk multiple.
Exit: short, a bar after entry has high >= entry price + entry risk OR low <= entry price - entry risk * reward-to-risk multiple.