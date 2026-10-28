Calculation: Smoothed bin volume = Gaussian-weighted average of raw volumes across all price bins; each bar's volume is distributed evenly across bins intersecting its high–low range (or open–close body if selected).
Calculation: POC = midpoint price of the bin with the highest smoothed volume in the rolling profile, including the current bar.
Calculation: Value Area High and Value Area Low = upper and lower edges of the contiguous bins expanded outward from the POC bin, each time adding the adjacent bin with greater or equal smoothed volume, until the selected share of total smoothed volume is reached.
Long: Close crosses above POC OR close crosses above Value Area High
Short: Close crosses below POC OR close crosses below Value Area Low