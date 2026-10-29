Calculation: Round level = nearest multiple of the configured round-number step; the step is either manually set or selected from price magnitude
Calculation: Band width = ATR × configured band-width multiplier
Calculation: In-band interaction = current bar’s high–low range intersects the band around the round level
Calculation: Bullish rejection = in-band interaction, close above the round level by the required band fraction, and lower-wick-to-range fraction above its minimum
Calculation: Bearish rejection = in-band interaction, close below the round level by the required band fraction, and upper-wick-to-range fraction above its minimum
Calculation: Rejection score = capped weighted sum of normalized wick strength, close distance from the level in ATR units, proximity to the level, recent band-interaction count, relative volume (or a fixed contribution when disabled), and round-step-to-ATR ratio
Calculation: Failure risk = capped sum of a magnet penalty, a failed-reference penalty, a penalty proportional to the missing close-distance score, and a penalty proportional to recent band-interaction count
Long: round-level context is valid AND distance to round level in ATR units is within the configured maximum AND bullish rejection AND rejection score meets the required score AND failure risk is below its threshold
Short: round-level context is valid AND distance to round level in ATR units is within the configured maximum AND bearish rejection AND rejection score meets the required score AND failure risk is below its threshold