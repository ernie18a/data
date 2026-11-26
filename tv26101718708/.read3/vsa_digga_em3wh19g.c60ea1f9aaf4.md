Calculation: spread = high - low
Calculation: close position = spread > 0 ? (close - low) / spread : midpoint
Calculation: narrow-spread threshold = nearest-rank percentile(spread, percentile lookback, narrow percentile)
Calculation: low-volume threshold = nearest-rank percentile(volume, percentile lookback, low-volume percentile)
Calculation: wide-spread threshold = nearest-rank percentile(spread, percentile lookback, wide percentile)
Calculation: high-volume threshold = nearest-rank percentile(volume, percentile lookback, high-volume percentile)
Calculation: ultra-high-volume threshold = nearest-rank percentile(volume, percentile lookback, ultra-high-volume percentile)
Calculation: swing high = highest(high[1], swing lookback)
Calculation: swing low = lowest(low[1], swing lookback)
Calculation: narrow bar = spread > 0 AND spread <= narrow-spread threshold, after the percentile and swing lookbacks are warmed
Calculation: low volume = volume <= low-volume threshold, or volume is ignored
Calculation: stopping-volume event = volume is used AND close < close[1] AND spread >= wide-spread threshold AND volume >= high-volume threshold AND close position >= midpoint
Calculation: buying-climax event = volume is used AND close > close[1] AND spread >= wide-spread threshold AND volume >= ultra-high-volume threshold AND high > swing high
Calculation: upthrust event = volume is used AND high > swing high AND close position <= lower third AND volume >= high-volume threshold
Calculation: spring event = low < swing low AND close > swing low AND close position >= midpoint
Calculation: No Supply tag = enabled AND volume is used AND close < close[1] AND narrow bar AND volume < volume[1] AND volume < volume[2]
Calculation: No Demand tag = enabled AND volume is used AND close > close[1] AND narrow bar AND volume < volume[1] AND volume < volume[2]
Calculation: Test tag = enabled AND volume is used AND low < low[1] AND close position >= midpoint AND volume <= low-volume threshold AND a stopping-volume or spring event occurred within the context window
Calculation: NR7 tag = enabled AND current spread is strictly narrower than each spread in its longer NR lookback
Calculation: NR4 tag = enabled AND current spread is strictly narrower than each spread in its shorter NR lookback AND NR7 tag is false
Calculation: Inside-bar tag = enabled AND high <= high[1] AND low >= low[1]
Calculation: Stopping-volume, buying-climax, upthrust, and spring context tags = their respective event occurred on the current bar or within the context window, and the corresponding tag is enabled
Calculation: Demand tag count = enabled No Supply, Test, NR4, NR7, Inside-bar, stopping-volume, and spring tags on the base bar
Calculation: Supply tag count = enabled No Demand, NR4, NR7, Inside-bar, buying-climax, and upthrust tags on the base bar
Calculation: Demand base = narrow bar AND low volume AND (EMA filter enabled ? close > EMA(close, EMA lookback) : close < close[1]) AND (close-bias filter disabled OR close position <= midpoint)
Calculation: Supply base = narrow bar AND low volume AND (EMA filter enabled ? close < EMA(close, EMA lookback) : close > close[1]) AND (close-bias filter disabled OR close position >= midpoint)
Calculation: Initial zone height = max(spread, minimum-height multiplier × median spread over the percentile lookback); initial zone bounds are centered on the base bar's midpoint
Long: A demand base creates a forming demand zone when its tag count meets the minimum-tag filter and no live confirmed demand zone overlaps it; when merging is enabled, an overlapping forming demand zone of the same kind widens to include the base bar and unions its tags. Signal when a later confirmed bar closes above the forming zone's top before a close below its bottom or the formation-age limit; discard forming zones on either cancellation condition. Live confirmed zones stop blocking new bases when broken, expired after the untouched-bar limit, or removed as the oldest zone at the live-zone cap.
Short: A supply base creates a forming supply zone when its tag count meets the minimum-tag filter and no live confirmed supply zone overlaps it; when merging is enabled, an overlapping forming supply zone of the same kind widens to include the base bar and unions its tags. Signal when a later confirmed bar closes below the forming zone's bottom before a close above its top or the formation-age limit; discard forming zones on either cancellation condition. Live confirmed zones stop blocking new bases when broken, expired after the untouched-bar limit, or removed as the oldest zone at the live-zone cap.