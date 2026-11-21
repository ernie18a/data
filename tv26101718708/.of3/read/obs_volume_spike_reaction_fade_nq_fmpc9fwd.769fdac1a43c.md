Calculation: VolumeSpike(i) = volume[i] >= SMA(volume, volume lookback)[i] * (volume multiplier RTH if current bar time (Chicago) is >= RTH start and < RTH end, else volume multiplier ETH)
Calculation: CandleBodyPct = 100 * abs(close - open) / (high - low), or 0 if high = low
Calculation: NearLevel(p) = some level in the static level set satisfies abs(level - p) <= level tolerance
Calculation: LevelOK(p) = level filter mode is off OR instrument excluded from level filtering OR (level filter mode is avoid AND NOT NearLevel(p)) OR (level filter mode is boost AND NearLevel(p))
Calculation: TriggerBar = VolumeSpike(0) AND high - low >= min range AND (NOT overshoot filter enabled OR (SMA(high - low, overshoot lookback)[1] > 0 AND high - low >= overshoot multiplier * SMA(high - low, overshoot lookback)[1])) AND NOT (VolumeSpike(i) for some i in 1 to cluster lookback) AND NOT (skip Asia enabled AND (bar time >= Asia start OR bar time < Asia end)) AND NOT (skip London enabled AND bar time >= London start AND bar time < London end) AND NOT (skip news enabled AND bar time >= news start AND bar time <= news end for either news window) AND NOT (skip session edges enabled AND abs(bar time - session edge time) <= edge buffer for some session edge time) AND NOT (regime filter enabled AND close < SMA(close, regime lookback) AND NOT (SMA(close, regime lookback) > SMA(close, regime lookback)[1] AND SMA(close, regime lookback)[1] > SMA(close, regime lookback)[2])) AND (NOT body filter enabled OR CandleBodyPct > rocket threshold OR CandleBodyPct < indecision threshold)
Calculation: LongSignal = TriggerBar AND long leg enabled AND LevelOK(LongEntry(current bar))
Calculation: ShortSignal = TriggerBar AND short leg enabled AND LevelOK(ShortEntry(current bar))
Calculation: LatestLongSignal = most recent bar at which LongSignal is true
Calculation: LatestShortSignal = most recent bar at which ShortSignal is true
Calculation: LongEntry(k) = low(k) - entry offset * (high(k) - low(k))
Calculation: LongStop(k) = low(k) - stop offset * (high(k) - low(k))
Calculation: LongTarget(k) = low(k) + target depth * (high(k) - low(k))
Calculation: ShortEntry(k) = high(k) + entry offset * (high(k) - low(k))
Calculation: ShortStop(k) = high(k) + stop offset * (high(k) - low(k))
Calculation: ShortTarget(k) = high(k) - target depth * (high(k) - low(k))
Long: LongSignal
Long: position side is not long AND low <= LongEntry(LatestLongSignal) AND bars since LatestLongSignal <= order TTL AND position side has not changed to long or short after LatestLongSignal
Short: ShortSignal
Short: position side is not short AND high >= ShortEntry(LatestShortSignal) AND bars since LatestShortSignal <= order TTL AND position side has not changed to long or short after LatestShortSignal
Exit: long, low <= LongStop(LatestLongSignal) OR high >= LongTarget(LatestLongSignal)
Exit: short, high >= ShortStop(LatestShortSignal) OR low <= ShortTarget(LatestShortSignal)