Calculation: Anchored VWAPs = Volume-weighted mean of (high + low + close) / 3 on chart bars, calculated separately from each anchor reset through the current bar; undefined when cumulative volume is zero. The session anchor resets on the first bar inside the configured session and is undefined outside it. The swing-high and swing-low anchors reset on the confirmation bar of a pivot high or pivot low, respectively, using the same number of bars on each side; each is undefined before its first confirmation. The day anchor resets on the first bar of each new day after a prior day-start bar has been observed and is undefined before its first reset.
Calculation: Active anchor count = Number of defined anchored VWAPs. Above count = Number of defined anchored VWAPs strictly below the close.
Long: Close > any anchored VWAP.
Short: Close < any anchored VWAP.
Long: Close > an anchored VWAP AND previous close <= the same anchored VWAP on the previous bar.
Short: Close < an anchored VWAP AND previous close >= the same anchored VWAP on the previous bar.
Long: Above count >= 3.
Short: Active anchor count >= 3 AND above count <= 1.