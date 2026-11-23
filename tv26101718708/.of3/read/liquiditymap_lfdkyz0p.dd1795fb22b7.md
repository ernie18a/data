Calculation: CloseLocation = (close - low) / (high - low) if high > low, else 0.5
Calculation: VolumeRatio = volume / SMA(volume, volume average length) if SMA(volume, volume average length) > 0, else 1
Calculation: LongEntryWeight = (open interest - open interest[1]) * min(VolumeRatio, volume weight cap) if open interest > open interest[1] AND VolumeRatio >= volume ratio threshold AND CloseLocation > 0.5, else 0
Calculation: ShortEntryWeight = (open interest - open interest[1]) * min(VolumeRatio, volume weight cap) if open interest > open interest[1] AND VolumeRatio >= volume ratio threshold AND CloseLocation <= 0.5, else 0
Calculation: LongShare = 100 * (sum of LongEntryWeight[k] for k from 0 to lookback - 1) / (sum of (LongEntryWeight[k] + ShortEntryWeight[k]) for k from 0 to lookback - 1), or 50 if that denominator is 0
Calculation: RangeLow = max(lowest(low, lookback) - range extension * (highest(high, lookback) - lowest(low, lookback)), 0)
Calculation: BinSize = (highest(high, lookback) + range extension * (highest(high, lookback) - lowest(low, lookback)) - RangeLow) / bin count
Calculation: BinMidpoint(b) = RangeLow + (b + 0.5) * BinSize
Calculation: LongLiqDensity(b) = sum over k from 0 to lookback - 1 of LongEntryWeight[k] * (sum of tier weight(t) over leverage tiers t with bin index(k, t) = b) / (sum of tier weight(t) over all leverage tiers), where bin index(k, t) = floor(((high[k] + low[k]) / 2 * (1 - 1 / tier leverage(t) + maintenance margin / 100) - RangeLow) / BinSize)
Calculation: ShortLiqDensity(b) = sum over k from 0 to lookback - 1 of ShortEntryWeight[k] * (sum of tier weight(t) over leverage tiers t with bin index(k, t) = b) / (sum of tier weight(t) over all leverage tiers), where bin index(k, t) = floor(((high[k] + low[k]) / 2 * (1 + 1 / tier leverage(t) - maintenance margin / 100) - RangeLow) / BinSize)
Calculation: MaxDensity = max over bins b from 0 to bin count - 1 of max(LongLiqDensity(b), ShortLiqDensity(b))
Long: open interest > open interest[1] AND VolumeRatio >= volume ratio threshold AND CloseLocation > 0.5
Short: open interest > open interest[1] AND VolumeRatio >= volume ratio threshold AND CloseLocation <= 0.5
Long: LongShare > heavy-share threshold
Short: LongShare <= heavy-share threshold AND 100 - LongShare > heavy-share threshold
Long: for some bin b from 0 to bin count - 1, LongLiqDensity(b) > MaxDensity * minimum density display % / 100
Short: for some bin b from 0 to bin count - 1, ShortLiqDensity(b) > MaxDensity * minimum density display % / 100
Long: for some bin b from 0 to bin count - 1, LongLiqDensity(b) >= MaxDensity * line density % / 100 AND BinMidpoint(b) < close AND close - BinMidpoint(b) >= close * minimum line distance % / 100
Short: for some bin b from 0 to bin count - 1, ShortLiqDensity(b) >= MaxDensity * line density % / 100 AND BinMidpoint(b) > close AND BinMidpoint(b) - close >= close * minimum line distance % / 100