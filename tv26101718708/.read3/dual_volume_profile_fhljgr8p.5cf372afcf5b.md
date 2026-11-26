Calculation: VolumeProfileValueArea(window, rows, pct) = [bottom edge of lowest bucket, top edge of highest bucket] of the band that starts at the bucket with the greatest volume among rows equal-width price buckets spanning the window's highest high to lowest low, where each bar's volume is added to the bucket containing (high + low) / 2, and that repeatedly adds the adjacent bucket with greater volume (upper bucket on tie, other side when one side has no bucket left) until the band's volume is at least pct percent of the window's total volume
Calculation: SessionVA = VolumeProfileValueArea(bars from the start of the current session per session schedule through the current bar, session rows, value-area percent)
Calculation: RangeVA = VolumeProfileValueArea(the last range lookback bars ending with the current bar, range rows, value-area percent)
Calculation: DivergencePct = ((SessionVA.low + SessionVA.high) / 2 - (RangeVA.low + RangeVA.high) / 2) / (RangeVA.high - RangeVA.low) * 100
Long: close > SessionVA.high AND close > RangeVA.high
Short: close < SessionVA.low AND close < RangeVA.low
Long: DivergencePct >= divergence threshold
Short: DivergencePct <= -divergence threshold