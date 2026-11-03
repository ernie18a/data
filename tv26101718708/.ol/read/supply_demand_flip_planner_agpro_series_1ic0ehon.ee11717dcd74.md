Calculation: Confirmed pivot high/low = a bar’s high/low is the highest/lowest over the configured left and right bars; available after the right-side bars complete.
Calculation: Supply zone = confirmed pivot high and a lower boundary below it by an ATR-scaled depth; demand zone = confirmed pivot low and an upper boundary above it by an ATR-scaled depth. Retain the latest zone of each type only while within its maximum age and until broken.
Calculation: Flip zone = the source zone’s price boundaries, retained after a close breaks beyond the source zone by an ATR-scaled buffer; a broken supply zone becomes a demand flip, and a broken demand zone becomes a supply flip. Retain the active flip only during its retest window, or while its acceptance remains active.
Calculation: Retest = a bar’s range overlaps the active flip zone; retest is recent for the configured number of bars after overlap.
Calculation: Acceptance score = weighted score from normalized break strength, retest depth, rejection wick, candle body ratio, source-zone quality, flip freshness, and relative volume; relative volume compares current volume with its recent average. Use the configured confirmation mode to adjust the minimum ready score.
Long: A confirmed pivot low maps a demand zone.
Long: Close > active supply zone upper edge + ATR-scaled break buffer.
Long: Active flip is a demand flip AND retest is recent AND close > flip zone upper edge + ATR-scaled acceptance buffer AND acceptance score >= minimum ready score adjusted by confirmation mode.
Short: A confirmed pivot high maps a supply zone.
Short: Close < active demand zone lower edge - ATR-scaled break buffer.
Short: Active flip is a supply flip AND retest is recent AND close < flip zone lower edge - ATR-scaled acceptance buffer AND acceptance score >= minimum ready score adjusted by confirmation mode.
Exit: Long, close < demand flip zone lower edge - ATR-scaled invalidation buffer.
Exit: Short, close > supply flip zone upper edge + ATR-scaled invalidation buffer.