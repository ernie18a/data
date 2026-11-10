Calculation: Confirmed swing high or low = a pivot high or low with equal-length left and right lookbacks, confirmed on the current bar; if both occur together, process only the swing high.
Calculation: Active supply and demand zones = on confirmation, propose a supply zone from swing high minus ATR times a width factor to swing high, or a demand zone from swing low to swing low plus ATR times the width factor. Use ATR on the confirmation bar. Reject the proposed zone if its midpoint is within or equal to an ATR-based distance of the midpoint of any active zone of the same type. Otherwise add it and discard the oldest zone of that type if the retained-zone limit is exceeded. After adding zones, remove each supply zone when close >= its top and each demand zone when close <= its bottom.
Calculation: Previous swing high or low = the preceding confirmed swing of the same type, initialized to zero.
Calculation: Anchored VWAP = cumulative volume-weighted average of a selected price source since the start of a selected calendar anchor period; initialize at the first available source value.
Long: A swing low is confirmed AND its proposed demand zone is accepted.
Long: A swing low is confirmed AND swing low >= previous swing low.
Long: Close >= the top of an active supply zone.
Long: Close > anchored VWAP.
Long: Anchored VWAP > previous bar's anchored VWAP.
Short: A swing high is confirmed AND its proposed supply zone is accepted.
Short: A swing high is confirmed AND swing high < previous swing high.
Short: A swing low is confirmed AND swing low < previous swing low.
Short: Close <= the bottom of an active demand zone.
Short: Close <= anchored VWAP.
Short: Anchored VWAP <= previous bar's anchored VWAP.