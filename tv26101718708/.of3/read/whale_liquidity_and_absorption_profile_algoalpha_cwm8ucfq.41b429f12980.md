Calculation: Profile bins = partition the range from the lowest to highest T1 close over the profile lookback into equal bins, using at least one minimum tick of range; assign each T1 close to its clamped bin. Recalculate on chart bars from their T1 bars, including any available forming T1 bar.
Calculation: Strength threshold = ascending-sorted T1 volumes over the profile lookback at zero-based index min(sample count - 1, max(0, floor(sample count * strength percentile / 100))).
Calculation: Profile volume(bin, side, strength) = sum of T1 volume assigned to the bin over the profile lookback, where buy means T1 close > open, sell means T1 close <= open, strong means volume >= Strength threshold, and weak means volume < Strength threshold.
Calculation: Delta(bin) = buy volume minus sell volume assigned to the bin over the profile lookback.
Calculation: Absorption(bin) = sum of T1 volume assigned to the bin when a buy T1 close lies in its parent chart bar's upper wick, or a sell T1 close lies in its parent chart bar's lower wick, over the profile lookback; the parent bar must have the corresponding wick.
Long: A profile bin has strong buy volume, or has weak buy volume while weak volume segments are enabled.
Short: A profile bin has strong sell volume, or has weak sell volume while weak volume segments are enabled.
Long: Delta(bin) > 0.
Short: Delta(bin) < 0.
Long: The current close is in a bin whose Delta is positive and whose absolute Delta equals the greatest absolute Delta across bins.
Short: The current close is in a bin whose Delta is negative and whose absolute Delta equals the greatest absolute Delta across bins.
Long: A T1 bar within the current chart bar has close > open and volume >= Strength threshold.
Short: A T1 bar within the current chart bar has close <= open and volume >= Strength threshold.
Long: Absorption(bin) is greater than Absorption in both adjacent bins, and current close > bin midpoint.
Short: Absorption(bin) is greater than Absorption in both adjacent bins, and current close <= bin midpoint.