Calculation: Bar range = high - low
Calculation: Prior 30-bar average range = average of the high - low ranges of the prior 30 completed chart bars
Calculation: Long limit entry = reaction bar low - entry offset × reaction bar range
Calculation: Short limit entry = reaction bar high + entry offset × reaction bar range
Calculation: Long target = reaction bar midpoint
Calculation: Short target = reaction bar midpoint
Calculation: Long stop = long entry - stop distance, where stop distance is measured in reaction bar ranges
Calculation: Short stop = short entry + stop distance, where stop distance is measured in reaction bar ranges
Long: reaction bar volume >= session-specific multiplier × 20-bar volume SMA AND reaction bar range >= minimum range AND reaction bar range >= overshoot multiplier × prior 30-bar average range AND no volume spike occurred in the prior cluster-filter lookback bars AND time is outside the skipped Asia and London sessions and session-edge buffers AND long entry is not within the level-filter tolerance of a static Fibonacci confluence level AND a later bar's low <= long limit entry
Short: reaction bar volume >= session-specific multiplier × 20-bar volume SMA AND reaction bar range >= minimum range AND reaction bar range >= overshoot multiplier × prior 30-bar average range AND no volume spike occurred in the prior cluster-filter lookback bars AND time is outside the skipped Asia and London sessions and session-edge buffers AND short entry is not within the level-filter tolerance of a static Fibonacci confluence level AND a later bar's high >= short limit entry
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target