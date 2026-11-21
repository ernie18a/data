Calculation: GapPct = (low - high[2]) / low * 100 if high[2] < low; (low[2] - high) / high * 100 if low[2] > high; otherwise 0
Calculation: GapSize = min(GapPct / PercentileNearestRank(GapPct, gap lookback, gap percentile) * 100, 100)
Calculation: BullShare = 100 * sum of volume of T1 bars inside the current bar where close > open / sum of volume of T1 bars inside the current bar where close != open, or 50 if that denominator is 0
Calculation: Strength(side) = int(GapSize * size weight + alignment * (1 - size weight)), where alignment = BullShare for bullish and 100 - BullShare for bearish
Calculation: MitBull = close, or low, per the mitigation source parameter
Calculation: MitBear = close, or high, per the mitigation source parameter
Calculation: BullZone = bullish zone formed on each bar where the bullish Long formation condition holds, with bottom = high[2], top = low, midpoint = (top + bottom) / 2 and strength = Strength(bullish) on that bar; it stays active until MitBull < midpoint
Calculation: BearZone = bearish zone formed on each bar where the bearish Short formation condition holds, with top = low[2], bottom = high, midpoint = (top + bottom) / 2 and strength = Strength(bearish) on that bar; it stays active until MitBear > midpoint
Long: close[1] > open[1] AND high[2] < low AND GapSize > minimum gap size AND Strength(bullish) >= minimum score
Long: low <= midpoint of an active BullZone whose strength >= high-score threshold
Short: close[1] < open[1] AND low[2] > high AND GapSize > minimum gap size AND Strength(bearish) >= minimum score
Exit: long, MitBull < midpoint of the BullZone the long was entered on
Exit: long, low < bottom of the BullZone the long was entered on
Exit: short, MitBear > midpoint of the BearZone the short was entered on