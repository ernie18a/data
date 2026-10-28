Calculation: Bar range = high − low
Calculation: Prior average range = average of prior completed bars’ high − low values
Calculation: Long entry limit = reaction bar low − entry offset × reaction bar range
Calculation: Short entry limit = reaction bar high + entry offset × reaction bar range
Calculation: Long target = reaction bar low + target depth × reaction bar range
Calculation: Short target = reaction bar high − target depth × reaction bar range
Calculation: Long stop = reaction bar low − stop distance × reaction bar range
Calculation: Short stop = reaction bar high + stop distance × reaction bar range
Long: Current bar volume ≥ session-specific multiplier × current-bar-including volume moving average AND current bar range ≥ minimum range AND (relative range filter off OR current bar range ≥ multiplier × prior completed bars’ longer-lookback average range) AND no volume spike occurred in the configured prior bars AND time and regime filters pass AND (body filter off OR body percentage > rocket threshold OR body percentage < indecision threshold) AND level filter passes AND price reaches the long entry limit
Short: Current bar volume ≥ session-specific multiplier × current-bar-including volume moving average AND current bar range ≥ minimum range AND (relative range filter off OR current bar range ≥ multiplier × prior completed bars’ longer-lookback average range) AND no volume spike occurred in the configured prior bars AND time and regime filters pass AND (body filter off OR body percentage > rocket threshold OR body percentage < indecision threshold) AND level filter passes AND price reaches the short entry limit
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target