Calculation: high-volume bar = volume > SMA(volume, volume lookback) × volume threshold AND (minimum-volume filter is disabled OR volume >= minimum-volume threshold)
Calculation: price factor = 1 when price-movement weighting is disabled; otherwise abs((close - open) / open) × price-movement scale
Calculation: block impact = 0 when the bar is not high-volume; otherwise sign(close - open) × volume / SMA(volume, volume lookback) / impact normalization × price factor
Calculation: cumulative impact = previous bar's cumulative impact × decay factor + block impact, initialized at zero
Long: cumulative impact crosses above zero
Short: cumulative impact crosses below zero
Long: cumulative impact > 0
Short: cumulative impact < 0
Long: high-volume bar AND close > open AND no accepted block-sell marking in the previous volume-lookback bars
Short: high-volume bar AND close < open AND no accepted block-buy marking in the previous volume-lookback bars
Calculation: consecutive bearish-pressure bars = consecutive bars ending on the current bar with cumulative impact <= 0; reset to zero when cumulative impact > 0
Calculation: consecutive bullish-pressure bars = consecutive bars ending on the current bar with cumulative impact >= 0; reset to zero when cumulative impact < 0
Calculation: exhaustion price-range percentage = abs(high - low) / ((high + low) / 2) × 100
Calculation: bearish-exhaustion reference high and low = high and low of the first bearish-exhaustion bar; retain until validation or invalidation
Calculation: bullish-exhaustion reference high and low = high and low of the first bullish-exhaustion bar; retain until validation or invalidation
Calculation: bars since exhaustion invalidation = increment each bar and reset to zero when the corresponding exhaustion is invalidated
Calculation: bearish exhaustion = cumulative impact < -extreme-impact threshold AND consecutive bearish-pressure bars >= exhaustion-bars threshold AND exhaustion price-range percentage <= exhaustion price threshold AND bars since bearish invalidation >= minimum-wait parameter AND NOT (previous bar was bearish exhaustion AND low < its reference low)
Calculation: bullish exhaustion = cumulative impact > extreme-impact threshold AND consecutive bullish-pressure bars >= exhaustion-bars threshold AND exhaustion price-range percentage <= exhaustion price threshold AND bars since bullish invalidation >= minimum-wait parameter AND NOT (previous bar was bullish exhaustion AND high > its reference high)
Long: previous bar was bearish exhaustion AND high > its reference high AND low >= its reference low
Short: previous bar was bullish exhaustion AND low < its reference low AND high <= its reference high
Exit: long, cumulative impact < -signal threshold
Exit: short, cumulative impact > signal threshold