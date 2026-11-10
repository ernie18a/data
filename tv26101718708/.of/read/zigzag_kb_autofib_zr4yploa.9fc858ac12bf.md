Calculation: Recent down-swing = the latest high-to-low segment in the fixed-percentage ZigZag, using its pivot-depth parameter. Snapshot its high A, low B, and B time when first found or when the latest down-swing's B time changes; retain the snapshot while B time is unchanged.
Calculation: Entry threshold = B + entry retracement fraction × (A − B).
Calculation: Target threshold = B + target retracement fraction × (A − B), where the target fraction is greater than the entry fraction.
Calculation: Setup played = false when a new down-swing snapshot is assigned; thereafter true once a confirmed bar's high reaches the current target threshold, including the assignment bar. Reset when a new snapshot is assigned.
Long: A recent down-swing exists AND setup played = false AND close > current entry threshold AND previous close <= current entry threshold AND (EMA filter disabled OR close > shorter EMA AND close > longer EMA) AND (volume filter disabled OR volume > volume SMA × volume multiplier).
Exit: long, high >= current target threshold.
Exit: long, high < current target threshold AND close < shorter EMA AND close < longer EMA.