Calculation: Zones = On confirmed chart bars, create resistance zones at confirmed PivotHigh(high, left lookback, right lookback) and support zones at confirmed PivotLow(low, left lookback, right lookback); center each at the pivot price with bounds center ± max(ATR(range lookback)[right lookback bars ago] × zone-width factor, minimum half-width); merge each new zone into the oldest same-side zone whose bounds overlap or whose center is within max(ATR(range lookback)[right lookback bars ago] × merge-distance factor, minimum merge distance), taking the union of bounds and setting the center to their midpoint; otherwise append it, then remove oldest zones until the count is at most the maximum-zones parameter
Calculation: Signed volume = if high = low then 0, else volume × clamp(body-weight × (close − open) / (high − low) + close-location-weight × (2 × (close − low) / (high − low) − 1), −signed-volume limit, signed-volume limit)
Calculation: Net impulse = SUM(signed volume, impulse lookback)
Calculation: Overall pressure = if SUM(abs(signed volume), impulse lookback) > 0 then neutral pressure + neutral pressure × net impulse / SUM(abs(signed volume), impulse lookback), else neutral pressure
Calculation: Zone pressure = percent(zone positive signed volume, zone positive signed volume + abs(zone negative signed volume)), or neutral pressure if the denominator is zero; accumulate signed volume from each creating or merging pivot and each confirmed chart bar touching the zone
Long: overall pressure ≥ neutral pressure
Short: overall pressure < neutral pressure
Long: net impulse ≥ 0
Short: net impulse < 0
Long: any zone has zone pressure ≥ neutral pressure
Short: any zone has zone pressure < neutral pressure
Long: any resistance zone has close > top
Short: any support zone has close < bottom
Long: any support zone has close > top AND zone pressure > upper hold-pressure threshold
Short: any resistance zone has close < bottom AND zone pressure < lower hold-pressure threshold
Long: on a confirmed chart bar, high ≥ bottom AND low ≤ top for any support zone, OR close > top AND close[1] ≤ top for any resistance zone
Short: on a confirmed chart bar, high ≥ bottom AND low ≤ top for any resistance zone, OR close < bottom AND close[1] ≥ bottom for any support zone