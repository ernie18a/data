Calculation: Choppiness Index = 100 × log(sum of true ranges over its lookback / (highest high − lowest low over the same lookback)) / log(lookback)
Calculation: Path efficiency = absolute change in close over its lookback / sum of absolute close changes over that lookback
Calculation: Range tightness = normalized inverse of the current decision-range span divided by its longer-term average span
Calculation: Wick noise = average of (bar range − absolute body) / bar range
Calculation: Chop score = smoothed weighted blend of Choppiness Index, inverse normalized ADX, inverse path efficiency, range tightness, and wick noise
Calculation: Active range = highest high and lowest low across consecutive bars whose chop score meets the chop threshold; retain its boundaries and age when that condition ends
Calculation: Readiness score = smoothed weighted blend of normalized range age, 3-bar chop-score decline, 3-bar ADX increase, 3-bar path-efficiency increase, ATR relative to its longer-term average, and distance of close from the range midpoint
Calculation: Release quality = normalized blend of readiness, range age, release distance in ATR, candle body share, close location toward the release direction, and relative volume quality; use neutral volume quality when volume participation is disabled
Calculation: ATR = average true range; use a longer lookback for its baseline than for current ATR
Calculation: Upside release boundary = last completed mature range high + current ATR × release buffer; downside release boundary = last completed mature range low − current ATR × release buffer
Calculation: Long invalidation = release range high − current ATR × invalidation buffer, adjusted so risk is at least a fraction of current ATR below entry; short invalidation is the mirrored level above entry
Calculation: Long targets = entry + risk × target multiples; short targets = entry − risk × target multiples, where risk is the distance from entry to invalidation
Long: On a confirmed bar, close crosses above the upside release boundary from at or below it, the completed range meets minimum age and is within the allowed post-range window, and release quality meets the minimum plan threshold
Short: On a confirmed bar, close crosses below the downside release boundary from at or above it, the completed range meets minimum age and is within the allowed post-range window, and release quality meets the minimum plan threshold
Exit: long, confirmed bar high reaches either target
Exit: short, confirmed bar low reaches either target
Exit: long, confirmed bar close is at or below invalidation after the entry bar
Exit: short, confirmed bar close is at or above invalidation after the entry bar
Exit: long or short, confirmed plan age exceeds the maximum active duration