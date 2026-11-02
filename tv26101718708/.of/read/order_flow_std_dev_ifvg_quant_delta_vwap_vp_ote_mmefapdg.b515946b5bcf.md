Calculation: Buy volume and sell volume = sum volume of completed lower-timeframe bars within each chart bar, assigning bars with close >= open to buy volume and the rest to sell volume; if there are no intrabars, assign all chart-bar volume to buy volume when close >= open and otherwise to sell volume.
Calculation: Delta = buy volume minus sell volume.
Calculation: Cumulative delta = sum of delta since the start of the chosen daily or weekly anchor period.
Calculation: Buy share = buy volume / chart-bar volume when volume > 0, otherwise 0.5; sell share = 1 - buy share.
Calculation: Bullish absorption = volume >= average volume * absorption-volume multiplier AND high - low <= ATR * absorption-range multiplier AND delta < 0 AND close >= (high + low) / 2; bearish absorption = volume >= average volume * absorption-volume multiplier AND high - low <= ATR * absorption-range multiplier AND delta > 0 AND close <= (high + low) / 2.
Calculation: Buy imbalance = volume > 0 AND buy share >= imbalance threshold; sell imbalance = volume > 0 AND sell share >= imbalance threshold.
Calculation: Recent buy pressure = SMA of buy volume / (SMA of buy volume + SMA of sell volume), using the same lookback for both averages; use 0.5 if their sum is zero.
Calculation: Anchored VWAP = cumulative sum of typical price * volume divided by cumulative volume since the chosen daily or weekly anchor; use typical price if cumulative volume is zero.
Calculation: Rolling value = rolling sum of typical price * volume divided by rolling sum of volume, with the denominator floored at a small positive constant.
Calculation: Volume z-score = (volume - SMA of volume) / standard deviation of volume over the same lookback, with the denominator floored at a small positive constant.
Calculation: Structure bias and retracement zone = maintain the latest two confirmed pivot highs and lows, with equal left and right pivot lookbacks. Bias starts bearish; once both pairs exist, set bullish when the latest high and low are both higher, bearish when both are lower, otherwise bearish when the latest high is lower, otherwise bullish when the latest low is higher, and otherwise retain the prior bias. With latest high H > latest low L, bullish zone bounds are H - (H - L) * farther retracement and H - (H - L) * nearer retracement; bearish bounds are L + (H - L) * nearer retracement and L + (H - L) * farther retracement. On the chart timeframe, optionally require the latest low to precede the latest high for bullish bias or the latest high to precede the latest low for bearish bias; retain the previous zone bounds when a valid leg or required order is absent. For each of two higher timeframes, use its own pivot calculations with the same shorter swing lookback, the bar still forming, and no swing-order requirement; its bounds are unavailable when H <= L. Zone direction follows the current bias.
Calculation: Gap lifecycle = on a confirmed chart bar, create a bullish gap with top = low and bottom = high two bars earlier when top > bottom and size >= gap-size multiplier * ATR; create a bearish gap with top = low two bars earlier and bottom = high when bottom < top and size >= gap-size multiplier * ATR. Mark a gap large when its creation size >= large-gap multiplier * ATR. A live bullish gap flips bearish when close < its midpoint or, under full-fill mode, its bottom; a live bearish gap flips bullish when close > its midpoint or, under full-fill mode, its top. Starting on subsequent bars, a flipped bearish gap retests when high >= bottom AND close < bottom AND the gap is large; a flipped bullish gap retests when low <= top AND close > top AND the gap is large. Invalidate a flipped bearish gap when close > top and a flipped bullish gap when close < bottom. Expire a live or flipped gap when its age since creation or most recent flip exceeds the expiry lookback, checking for a flip or retest before expiry; retain only the most recent configured maximum number of gaps.
Calculation: Bullish score = count of delta > 0, cumulative delta > cumulative delta at a prior lookback, close > anchored VWAP, close > rolling value, volume z-score > threshold, and (buy imbalance OR bullish absorption). Bearish score = count of delta < 0, cumulative delta < cumulative delta at the same prior lookback, close < anchored VWAP, close <= rolling value, volume z-score > the same threshold, and (sell imbalance OR bearish absorption).
Long: Delta >= 0.
Short: Delta < 0.
Long: Cumulative delta >= 0 OR cumulative delta > cumulative delta at the prior lookback.
Short: Cumulative delta < 0 OR cumulative delta < cumulative delta at the prior lookback.
Long: Recent buy pressure >= upper pressure threshold.
Short: Recent buy pressure <= lower pressure threshold.
Long: Buy imbalance.
Short: Sell imbalance.
Long: Buy imbalance AND previous-bar buy imbalance.
Short: Sell imbalance AND previous-bar sell imbalance.
Long: Bullish absorption.
Short: Bearish absorption.
Long: Structure bias is bullish AND two confirmed pivot highs and two confirmed pivot lows exist.
Short: Structure bias is bearish AND two confirmed pivot highs and two confirmed pivot lows exist.
Long: Bullish retracement-zone bounds exist AND close >= lower bound AND close <= upper bound.
Short: Bearish retracement-zone bounds exist AND close >= lower bound AND close <= upper bound.
Long: A bearish gap flips bullish AND the gap is large.
Short: A bullish gap flips bearish AND the gap is large.
Long: A flipped bullish gap retests.
Short: A flipped bearish gap retests.
Long: Bullish score >= score threshold AND bullish score >= bearish score AND (location gate disabled OR close inside a bullish chart or higher-timeframe retracement zone OR a flipped bullish gap retests).
Short: Bearish score >= score threshold AND bearish score > bullish score AND (location gate disabled OR close inside a bearish chart or higher-timeframe retracement zone OR a flipped bearish gap retests).
Long: Chart bar is confirmed AND bars since the last long or short signal > cooldown AND bullish score >= score threshold AND bullish score > bearish score AND (location gate disabled OR close inside a bullish chart or higher-timeframe retracement zone OR a flipped bullish gap retests).
Short: Chart bar is confirmed AND bars since the last long or short signal > cooldown AND bearish score >= score threshold AND bearish score > bullish score AND (location gate disabled OR close inside a bearish chart or higher-timeframe retracement zone OR a flipped bearish gap retests).