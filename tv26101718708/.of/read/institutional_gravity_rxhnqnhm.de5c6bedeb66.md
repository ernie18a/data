Calculation: ATR = average true range over a fixed lookback on the chart timeframe
Calculation: pad = small multiple of ATR; merge_dist = larger multiple of ATR than pad; cluster_dist = larger multiple of ATR than merge_dist
Calculation: rolling VWAP = sum(hlc3*volume)/sum(volume) over a trailing calendar-day window (short-term, shorter than a year); rolling SD = population standard deviation of hlc3 around rolling VWAP over the same window (not volume-weighted)
Calculation: yearly VWAP = sum(hlc3*volume)/sum(volume) anchored at the first bar of the current calendar year (long-term); yearly SD = population standard deviation of hlc3 around yearly VWAP since that anchor (not volume-weighted)
Calculation: levels = {rolling VWAP, rolling VWAP+SD, rolling VWAP-SD, yearly VWAP, yearly VWAP+SD, yearly VWAP-SD, short SMA of close, long SMA of close}, all on the chart timeframe, using the current bar
Calculation: cluster(L) = set of levels within cluster_dist of level L (including L)
Calculation: zone(L) = [min(cluster(L)) - pad, max(cluster(L)) + pad]; same-side zones whose ranges overlap within merge_dist are merged into one zone (union of ranges)
Calculation: pivot low = bar whose low is the lowest among the N bars before and N bars after it (confirmed N bars later); pivot high = bar whose high is the highest among the N bars before and after it
Long: a level L in levels with L < close AND (count(cluster(L)) >= 2 OR L is a VWAP or a VWAP±SD band) marks long zone(L)
Long: pivot low confirmed marks long zone [pivot low - pad, pivot low + pad]
Long: marks long zone [lowest low over a long lookback - pad, lowest low over that lookback + pad]
Short: a level L in levels with L >= close AND (count(cluster(L)) >= 2 OR L is a VWAP or a VWAP±SD band) marks short zone(L)
Short: pivot high confirmed marks short zone [pivot high - pad, pivot high + pad]
Short: marks short zone [highest high over a long lookback - pad, highest high over that lookback + pad]