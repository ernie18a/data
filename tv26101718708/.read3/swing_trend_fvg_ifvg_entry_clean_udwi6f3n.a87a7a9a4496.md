Calculation: body = |close - open|
Calculation: range = high - low
Calculation: lower wick = min(open, close) - low
Calculation: upper wick = high - max(open, close)
Calculation: bullish candle filter = (hammer filter enabled AND lower wick >= wick-to-body ratio * body AND upper wick <= opposite-wick fraction * body AND close - low >= bullish close-location threshold * range) OR (doji filter enabled AND body <= doji body fraction * range)
Calculation: bearish candle filter = (hammer filter enabled AND upper wick >= wick-to-body ratio * body AND lower wick <= opposite-wick fraction * body AND close - low <= bearish close-location threshold * range) OR (doji filter enabled AND body <= doji body fraction * range)
Calculation: pivot high(k) = high of the k-th most recent bar, at least N bars old, whose high is the highest of the 2 * N + 1 bars centered on it, where N = structure pivot length
Calculation: pivot low(k) = low of the k-th most recent bar, at least N bars old, whose low is the lowest of the 2 * N + 1 bars centered on it, where N = structure pivot length
Calculation: bullish structure = (NOT 2-point enabled OR (pivot high(1) > pivot high(2) AND pivot low(1) > pivot low(2))) AND (NOT 3-point enabled OR (pivot high(1) > pivot high(2) AND pivot high(2) > pivot high(3) AND pivot low(1) > pivot low(2) AND pivot low(2) > pivot low(3)))
Calculation: bearish structure = (NOT 2-point enabled OR (pivot high(1) < pivot high(2) AND pivot low(1) < pivot low(2))) AND (NOT 3-point enabled OR (pivot high(1) < pivot high(2) AND pivot high(2) < pivot high(3) AND pivot low(1) < pivot low(2) AND pivot low(2) < pivot low(3)))
Calculation: bullish trend = (NOT EMA trend enabled OR (EMA(close, shorter EMA length) > EMA(close, longer EMA length) AND close > EMA(close, shorter EMA length))) AND (NOT structure trend enabled OR bullish structure)
Calculation: bearish trend = (NOT EMA trend enabled OR (EMA(close, shorter EMA length) < EMA(close, longer EMA length) AND close < EMA(close, shorter EMA length))) AND (NOT structure trend enabled OR bearish structure)
Calculation: bullish swing start = (5-candle model enabled AND low[L] < low[k] for every k from 0 to 2 * L other than L AND bullish candle filter[L] AND (NOT sweep required OR low[L] < previous bullish pivot low)) OR (2-candle model enabled AND lower wick[1] >= wick-to-body ratio * body[1] AND close > open AND lower wick <= 2-candle opposite-wick fraction * body AND (NOT sweep required OR low[1] < low[2])), where L = swing pivot length
Calculation: bearish swing start = (5-candle model enabled AND high[L] > high[k] for every k from 0 to 2 * L other than L AND bearish candle filter[L] AND (NOT sweep required OR high[L] > previous bearish pivot high)) OR (2-candle model enabled AND upper wick[1] >= wick-to-body ratio * body[1] AND close < open AND upper wick <= 2-candle opposite-wick fraction * body AND (NOT sweep required OR high[1] > high[2])), where L = swing pivot length
Calculation: bullish setup start = bullish swing start AND bullish trend
Calculation: bearish setup start = bearish swing start AND bearish trend
Calculation: volume confirmed = (NOT volume filter enabled) OR volume > SMA(volume, volume length) * volume multiple
Calculation: bullish FVG = FVG enabled AND low > high[2] AND low - high[2] >= minimum FVG ticks * tick size
Calculation: bearish FVG = FVG enabled AND high < low[2] AND low[2] - high >= minimum FVG ticks * tick size
Calculation: bullish IFVG = IFVG enabled AND close > top of a bearish FVG formed at bar s AND that bearish FVG's size >= minimum IFVG ticks * tick size AND close <= that top on every bar from s to the prior bar
Calculation: bearish IFVG = IFVG enabled AND close < bottom of a bullish FVG formed at bar s AND that bullish FVG's size >= minimum IFVG ticks * tick size AND close >= that bottom on every bar from s to the prior bar
Calculation: bullish zone candidate = close > open AND body >= displacement ATR multiple * ATR(ATR length) AND close > EMA(close, shorter EMA length) AND (bullish FVG OR bullish IFVG)
Calculation: bearish zone candidate = close < open AND body >= displacement ATR multiple * ATR(ATR length) AND close < EMA(close, shorter EMA length) AND (bearish FVG OR bearish IFVG)
Calculation: bullish setup pending = bullish setup start OR (bullish setup pending[1] AND NOT bullish zone candidate)
Calculation: bearish setup pending = bearish setup start OR (bearish setup pending[1] AND NOT bearish zone candidate)
Calculation: bullish zone formed = bullish zone candidate AND (bullish setup pending[1] OR bullish setup start)
Calculation: bearish zone formed = bearish zone candidate AND (bearish setup pending[1] OR bearish setup start)
Calculation: bullish zone top = low at the latest bar where bullish zone formed holds, if a bullish FVG forms there; otherwise the top of the most recent bearish FVG flipped to a bullish IFVG there
Calculation: bullish zone bottom = high[2] at the latest bar where bullish zone formed holds, if a bullish FVG forms there; otherwise the bottom of the most recent bearish FVG flipped to a bullish IFVG there
Calculation: bearish zone top = low[2] at the latest bar where bearish zone formed holds, if a bearish FVG forms there; otherwise the top of the most recent bullish FVG flipped to a bearish IFVG there
Calculation: bearish zone bottom = high at the latest bar where bearish zone formed holds, if a bearish FVG forms there; otherwise the bottom of the most recent bullish FVG flipped to a bearish IFVG there
Calculation: bullish zone live = bullish zone formed OR (bullish zone active[1] AND NOT bullish setup start)
Calculation: bearish zone live = bearish zone formed OR (bearish zone active[1] AND NOT bearish setup start)
Calculation: bullish zone invalid = bars since the swing bar of the latest bullish setup start > setup expiry bars OR (full-break invalidation enabled AND low < bullish zone bottom AND close < bullish zone bottom)
Calculation: bearish zone invalid = bars since the swing bar of the latest bearish setup start > setup expiry bars OR (full-break invalidation enabled AND high > bearish zone top AND close > bearish zone top)
Calculation: bullish zone touched = (low <= bullish zone top AND (NOT refined-half required OR low <= (bullish zone top + bullish zone bottom) / 2) AND high >= bullish zone bottom) OR (bullish zone touched[1] AND bullish zone active[1] AND NOT bullish setup start)
Calculation: bearish zone touched = (high >= bearish zone bottom AND (NOT refined-half required OR high >= (bearish zone top + bearish zone bottom) / 2) AND low <= bearish zone top) OR (bearish zone touched[1] AND bearish zone active[1] AND NOT bearish setup start)
Calculation: bullish retest confirmation = close > open AND (NOT close-out required OR close > bullish zone top) AND volume confirmed
Calculation: bearish retest confirmation = close < open AND (NOT close-out required OR close < bearish zone bottom) AND volume confirmed
Calculation: bullish zone active = bullish zone live AND NOT (bullish zone invalid OR (bullish zone touched AND bullish retest confirmation))
Calculation: bearish zone active = bearish zone live AND NOT (bearish zone invalid OR (bearish zone touched AND bearish retest confirmation))
Long: bullish setup start
Long: gap-close mode AND bullish zone formed AND volume confirmed
Long: retest mode AND bullish zone live AND NOT bullish zone invalid AND bullish zone touched AND bullish retest confirmation
Short: bearish setup start
Short: gap-close mode AND bearish zone formed AND volume confirmed
Short: retest mode AND bearish zone live AND NOT bearish zone invalid AND bearish zone touched AND bearish retest confirmation