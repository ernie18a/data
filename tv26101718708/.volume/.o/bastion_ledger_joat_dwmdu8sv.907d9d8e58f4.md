Calculation: Confirmed pivot high/low = a high/low that remains the highest/lowest across the configured bars to its left and right; usable only after the right-side bars have completed
Calculation: Pivot demand zone = zone from a confirmed pivot low, bounded by the pivot low minus 0.18 × ATR padding and the pivot candle’s lower body edge plus 0.10 × ATR padding
Calculation: Pivot supply zone = zone from a confirmed pivot high, bounded by the pivot candle’s upper body edge minus 0.10 × ATR padding and the pivot high plus 0.18 × ATR padding
Calculation: Impulse demand zone = zone from a bullish impulse bar, bounded by its low minus 0.16 × ATR padding and its body top plus 0.08 × ATR padding
Calculation: Impulse supply zone = zone from a bearish impulse bar, bounded by its body bottom minus 0.08 × ATR padding and its high plus 0.16 × ATR padding
Calculation: Impulse bar = confirmed bar with volume / volume SMA above its threshold and absolute body size / bar range above its threshold
Calculation: Zone bounds = expand zone symmetrically as needed to reach the configured minimum height
Calculation: Eligible zone = zone that does not overlap an existing non-archived zone of the same type; archive a zone when its age exceeds the configured active life
Long: A new demand zone is created: a confirmed pivot low passes the optional volume gate, OR a bullish impulse bar occurs, AND its zone is eligible; OR the close crosses above the last confirmed pivot high (current close > pivot high AND previous close ≤ pivot high)
Short: A new supply zone is created: a confirmed pivot high passes the optional volume gate, OR a bearish impulse bar occurs, AND its zone is eligible; OR the close crosses below the last confirmed pivot low (current close < pivot low AND previous close ≥ pivot low)