Calculation: Estimated buy volume per bar = volume × (close − low) / (high − low) when high > low, otherwise volume / 2.
Calculation: Chart delta = 2 × estimated buy volume − volume, on the current chart bar, which may still be forming.
Calculation: FVG gap size(T) = low[1] − high[3] for bullish gaps; low[3] − high[1] for bearish gaps, using completed T bars.
Calculation: Minimum FVG gap(T) = ATR(ATR lookback, T, last completed bar) × ATR gap multiplier when ATR filtering is enabled; otherwise close[1] × minimum gap percentage / 100 when that percentage is positive; otherwise 0.
Calculation: FVG buy volume(T) = sum of estimated buy volume on T bars [1] through [3], using completed bars.
Calculation: FVG total volume(T) = volume[1] + volume[2] + volume[3] on completed T bars.
Calculation: FVG net delta(T) = 2 × FVG buy volume(T) − FVG total volume(T).
Calculation: FVG absorption(T) = sum, for T bars [1] through [3], of volume × ((high − max(open, close)) + (min(open, close) − low)) / (high − low) × 0.5 when high > low, otherwise 0.
Calculation: FVG strength(direction, gap, T) = clamp(score scale × weighted mean of displacement, delta alignment, relative volume, flow dominance, middle-candle body, and absorption scores, 0, score scale); use separate weight parameters for the six scores; displacement = clamp(gap / max(ATR(ATR lookback, T, last completed bar) × displacement ATR scale, ATR denominator floor), 0, 1); delta alignment = clamp(signed FVG net delta / FVG total volume, 0, 1) when volume is positive, otherwise 0, with signed delta positive for bullish and negated for bearish; relative volume = clamp(FVG total volume / (SMA(volume, relative-volume baseline, T)[1] × relative-volume denominator scale) / relative-volume score divisor, 0, 1) when the average is positive, otherwise 0; flow dominance = clamp(abs(FVG net delta) / max(FVG total volume, volume denominator floor), 0, 1); middle-candle body = clamp(abs(close[2] − open[2]) / (high[2] − low[2]), 0, 1) when its range is positive, otherwise 0; absorption = clamp(FVG absorption / max(FVG total volume, volume denominator floor) × absorption scale, 0, 1); divide the weighted sum by max(sum of weights, weight-sum floor).
Calculation: CVD bias = EMA(chart delta, CVD lookback) / max(EMA(volume, CVD lookback), volume denominator floor), on the current chart bar, which may still be forming.
Calculation: Active-zone delta sum(scope) = sum of FVG net delta across active zones, selecting zones associated with scope T or all active zones for the all-timeframe scope.
Calculation: Active zone bounds = raw FVG bounds, or the same midpoint with height set by chart ATR × zone-height ATR multiplier or chart close × zone-height percentage when normalization is enabled; when same-direction zones overlap or are within chart ATR × merge-distance parameter, repeatedly recenter the merged zone at the volume-weighted midpoint, retaining the first zone's height unless normalization is enabled.
Long: On a confirmed chart bar, a newly detected bullish FVG on any enabled T1, T2, or T3, using completed bars of that timeframe with low[1] > high[3] and FVG gap size(T) ≥ minimum FVG gap(T), when bullish detection is enabled.
Short: On a confirmed chart bar, a newly detected bearish FVG on any enabled T1, T2, or T3, using completed bars of that timeframe with high[1] < low[3] and FVG gap size(T) ≥ minimum FVG gap(T), when bearish detection is enabled.
Long: On a confirmed chart bar, a newly detected bullish FVG on any enabled T1, T2, or T3, using completed bars of that timeframe with low[1] > high[3], FVG gap size(T) ≥ minimum FVG gap(T), and bullish FVG strength ≥ minimum strength, when bullish detection is enabled.
Short: On a confirmed chart bar, a newly detected bearish FVG on any enabled T1, T2, or T3, using completed bars of that timeframe with high[1] < low[3], FVG gap size(T) ≥ minimum FVG gap(T), and bearish FVG strength ≥ minimum strength, when bearish detection is enabled.
Exit: long, on a confirmed chart bar, an active bullish zone reaches its selected mitigation boundary: low ≤ zone top for Touch, low ≤ (zone top + zone bottom) / 2 for 50% fill, or low ≤ zone bottom for Full Fill.
Exit: short, on a confirmed chart bar, an active bearish zone reaches its selected mitigation boundary: high ≥ zone bottom for Touch, high ≥ (zone top + zone bottom) / 2 for 50% fill, or high ≥ zone top for Full Fill.
Long: On the last chart bar, enabled timeframe T has at least one active zone and Active-zone delta sum(T) > 0.
Short: On the last chart bar, enabled timeframe T has at least one active zone and Active-zone delta sum(T) < 0.
Long: On the last chart bar, Active-zone delta sum(all) ≥ 0.
Short: On the last chart bar, Active-zone delta sum(all) < 0.
Long: Chart delta ≥ 0.
Short: Chart delta < 0.
Long: CVD bias ≥ 0.
Short: CVD bias < 0.