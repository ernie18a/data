Calculation: ATR = average true range on the chart bars.
Calculation: Confirmed pivot high/low = a bar whose high/low is an extreme against the configured number of bars on both sides, known only after the right-side bars complete.
Calculation: Shelf ledger = Register each confirmed pivot using the current ATR and volume. Merge it into the last tracked shelf within the configured ATR-distance tolerance, incrementing touches and recentering price as the mean of old and pivot prices; otherwise add a shelf with one touch. Remove the oldest shelf when capacity is exceeded.
Calculation: Nearest strong shelf = tracked shelf with the smallest absolute distance from current close among shelves meeting the configured minimum touch count.
Calculation: Shelf rejection buffer = configured fraction of current ATR.
Calculation: Upward shelf rejection = a nearest strong shelf exists AND low <= shelf price + buffer AND high >= shelf price - buffer AND close > shelf price + buffer AND close > open.
Calculation: Downward shelf rejection = a nearest strong shelf exists AND low <= shelf price + buffer AND high >= shelf price - buffer AND close < shelf price - buffer AND close < open.
Calculation: Reclaim EMA = exponential moving average of close.
Long: Upward shelf rejection.
Short: Downward shelf rejection.
Long: session filter passes AND cooldown has elapsed AND bar is confirmed AND position is not long AND (rejection-only mode is enabled AND upward shelf rejection OR rejection-only mode is disabled AND latest shelf rejection bias is bullish AND close crosses above reclaim EMA).
Short: session filter passes AND cooldown has elapsed AND bar is confirmed AND position is not short AND (rejection-only mode is enabled AND downward shelf rejection OR rejection-only mode is disabled AND latest shelf rejection bias is bearish AND close crosses below reclaim EMA).