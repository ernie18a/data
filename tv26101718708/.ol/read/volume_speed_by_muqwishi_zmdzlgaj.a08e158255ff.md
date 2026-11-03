Calculation: Selected volume = lower-timeframe volume or (high + low + close) / 3 × volume
Calculation: Average selected volume = sum of selected volumes across the most recent valid lower-timeframe bars, excluding the two oldest, divided by the number included
Calculation: Lower-timeframe direction = sign of the latest lower-timeframe close change from the preceding lower-timeframe close, retaining the last nonzero direction when closes are equal
Long: Current still-forming lower-timeframe selected volume ≥ Average selected volume × threshold AND Lower-timeframe direction is positive
Short: Current still-forming lower-timeframe selected volume ≥ Average selected volume × threshold AND Lower-timeframe direction is negative