Calculation: Signed volume = volume multiplied by the clamped weighted sum of body bias and close-location bias; body bias is (close - open) / (high - low), and close-location bias is 2 × (close - low) / (high - low) - 1. Use zero for both biases when high equals low. The positive weights sum to one, with the body-bias weight larger; clamp the sum to [-1, 1].
Calculation: Active zones = confirmed pivot-high resistance zones and pivot-low support zones. At confirmation, center each new zone on the pivot and set its half-width to the greater of pivot-bar ATR multiplied by a width parameter and a minimum-width parameter. Set its merge distance to the greater of pivot-bar ATR multiplied by a merge-distance parameter and twice the minimum-width parameter. Merge it into the oldest existing same-side zone whose boundaries overlap it or whose midpoint is within the merge distance; use the outermost boundaries and their midpoint. Otherwise append it as a new zone, removing the oldest zone if the maximum count is exceeded. Process pivot highs before pivot lows. Zones remain active after breaks.
Calculation: Zone pressure = positive signed volume accumulated for a zone divided by the sum of positive signed volume and absolute negative signed volume accumulated for that zone; use one-half when the sum is zero. On creation or merge, add the pivot bar's signed volume. On each confirmed bar, including the confirmation bar, also add that bar's signed volume when its high is at least the zone bottom and its low is at most the zone top.
Calculation: Ledger impulse = sum of signed volume over a lookback.
Long: On a confirmed bar, high >= an active support zone's bottom AND low <= its top.
Short: On a confirmed bar, high >= an active resistance zone's bottom AND low <= its top.
Long: Close > an active resistance zone's top.
Short: Close < an active support zone's bottom.
Long: Close > an active support zone's top AND its zone pressure > an upper pressure threshold.
Short: Close < an active resistance zone's bottom AND its zone pressure < a lower pressure threshold.
Long: An active zone's pressure >= one-half.
Short: An active zone's pressure < one-half.
Long: Ledger impulse >= zero.
Short: Ledger impulse < zero.