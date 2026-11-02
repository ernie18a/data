Calculation: Supply zone = on confirmation of a pivot high with an equal number of bars on each side, replace the previous supply zone; its top is the pivot high, or the average of this and the preceding pivot high if their distance is at most ATR times the cluster tolerance; its bottom is its top minus ATR times the zone-width multiplier. Use ATR at confirmation. The zone becomes active at confirmation.
Calculation: Demand zone = on confirmation of a pivot low with an equal number of bars on each side, replace the previous demand zone; its bottom is the pivot low, or the average of this and the preceding pivot low if their distance is at most ATR times the cluster tolerance; its top is its bottom plus ATR times the zone-width multiplier. Use ATR at confirmation. The zone becomes active at confirmation.
Calculation: Zone release = an active zone is released when its age since confirmation is at least the minimum age AND, if the body-quality filter is enabled, abs(close - open) / (high - low) is at least the body-quality threshold, with zero quality when high equals low AND either close exceeds the supply top or close is below the demand bottom; alternatively use high and low respectively instead of close. A released zone remains available until replaced by a new zone of the same type, or until its age since release exceeds the fade period if broken-zone retention is disabled. Evaluate retests before releases and expiry on each bar.
Long: A demand pivot is confirmed.
Long: Demand zone is active AND high >= demand bottom AND low <= demand top.
Long: Supply zone is released on the current bar.
Long: Demand zone was released on an earlier bar AND high >= demand bottom AND close <= demand top.
Short: A supply pivot is confirmed.
Short: Supply zone is active AND high >= supply bottom AND low <= supply top.
Short: Demand zone is released on the current bar.
Short: Supply zone was released on an earlier bar AND low <= supply top AND close >= supply bottom.