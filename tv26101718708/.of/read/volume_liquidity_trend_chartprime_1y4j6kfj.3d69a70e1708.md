Calculation: Filtered price = coefficient × selected price source + (1 − coefficient) × filtered price a configurable number of bars ago; use zero when the historical filtered price is unavailable.
Calculation: Upper and lower bands = filtered price plus and minus ATR multiplied by a configurable factor.
Calculation: Trend state = bearish initially; set bullish when close crosses above the upper band, set bearish when close crosses below the lower band, and otherwise retain the previous state. A cross above requires the current close to be above the current band and the previous close to be at or below the previous band; a cross below uses the inverse comparisons.
Long: Trend state = bullish.
Short: Trend state = bearish.