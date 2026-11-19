Calculation: session VWAP = VWAP(source, max(volume, 1), current session)
Calculation: session standard deviation = sqrt(max(VWAP(source², max(volume, 1), current session) − session VWAP², 0))
Calculation: smoothed z-score = EMA((close − session VWAP) / session standard deviation, smoothing parameter), reset at session start, seeded with the first valid value, and updated after the minimum-bars parameter and positive standard deviation are reached
Long: on a confirmed bar, smoothed z-score crosses above the extreme-threshold parameter
Short: on a confirmed bar, smoothed z-score crosses below the negative extreme-threshold parameter
Exit: long or short, on a confirmed bar, smoothed z-score crosses zero after its absolute value reached the extreme-threshold parameter earlier in the same session since the last return signal or session start