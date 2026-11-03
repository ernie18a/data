Calculation: Cross above A = close > A AND previous close <= previous A; cross below A = close < A AND previous close >= previous A.
Calculation: Confirmed pivot high or low = a high or low with an equal configured number of bars on each side satisfying the pivot-high or pivot-low test; it becomes available only after the right-side bars complete. Latest pivots include pivots confirmed on the current bar.
Calculation: Efficiency = EMA of absolute source change over its lookback divided by the sum of absolute bar-to-bar source changes over that lookback; use zero when the denominator is zero.
Calculation: Adaptive range filter = initialize to source; on each bar, set it to source minus ATR times an efficiency-adjusted multiplier if source exceeds the previous filter plus that buffer, to source plus the buffer if source is below the previous filter minus the buffer, and otherwise retain the previous filter. Use one multiplier adjustment below a low efficiency threshold, another above a high threshold, and no adjustment between them.
Calculation: Locked regime = initialize bullish if the range filter has no direction; otherwise initialize to its direction. Filter direction is bullish when the filter rises, bearish when it falls, and otherwise retains its previous direction. Change locked regime to the opposing filter direction after it persists for an efficiency-dependent confirmation count; use progressively shorter confirmation counts as efficiency increases.
Calculation: Reference pivot = mean of high, low, and close of the last completed reference-timeframe bar. The reference timeframe may be higher or lower than the chart timeframe.
Calculation: Higher-timeframe bias = bullish if the last completed higher-timeframe close exceeds its EMA on that completed bar; otherwise bearish.
Calculation: Weave bias = bullish if close > reference pivot AND short EMA > medium EMA AND the mean of short, medium, and long EMAs > that mean a configured number of bars earlier; bearish if all three comparisons reverse; otherwise neutral. All three EMAs use close and have increasing lookbacks.
Calculation: Geometry bias = bullish if the latest confirmed pivot low > the preceding confirmed pivot low; otherwise bearish if the latest confirmed pivot high < the preceding confirmed pivot high; otherwise neutral.
Calculation: Choppiness = 100 times log10(sum of true range over its lookback divided by highest high minus lowest low over that lookback) divided by log10 of the lookback; use a neutral fallback when the high-low range is zero.
Calculation: Bearish divergence = two consecutive confirmed divergence-lookback pivot highs no more than a configured number of bars apart, with the later high higher AND RSI at the later pivot lower. Bullish divergence uses pivot lows, a lower later low, and a higher later RSI. A divergence remains recent through a configured number of bars measured from the later pivot bar; it is available only after that pivot is confirmed.
Calculation: Bullish structure break = close > latest confirmed pivot high AND previous close <= that same pivot high AND (displacement requirement disabled OR absolute close minus open >= ATR times displacement multiplier). Bearish structure break reverses the price comparisons and uses the latest confirmed pivot low.
Calculation: Bullish gap = low > high a configured number of bars earlier; bearish gap = high < low the same number of bars earlier. A gap is recent if it occurred on the current bar or within a configured preceding window.
Calculation: Bullish continuation = continuation enabled AND locked regime bullish AND close crosses above the adaptive range filter AND close > reference pivot AND close > reversion EMA. Bearish continuation reverses the regime and comparisons.
Calculation: Bullish rotation = aggressive entries enabled AND (locked regime bullish OR close > adaptive range filter) AND (close crosses above reference pivot OR reversion EMA OR short EMA). Bearish rotation reverses the regime and comparisons.
Calculation: Regime gate = (ADX >= its floor OR choppiness <= its ceiling OR higher-timeframe bias = locked regime OR aggressive entries enabled) AND (higher-timeframe gate disabled OR higher-timeframe bias = locked regime).
Calculation: Long alignment = count of true comparisons among weave bias >= neutral, geometry bias >= neutral, close > adaptive range filter, and close > reference pivot. Short alignment uses <= neutral and the reversed price comparisons.
Calculation: Long entry stack = (locked regime bullish OR close > adaptive range filter OR short EMA > medium EMA) AND regime gate AND ((bullish structure break AND recent bullish gap) OR bullish continuation OR bullish rotation) AND (reclaim requirement disabled OR (low < reversion EMA AND close > reversion EMA) OR bullish continuation OR bullish rotation) AND long alignment >= required count AND (divergence block disabled OR recent bearish divergence absent). Short entry stack reverses direction and comparisons and blocks recent bullish divergence.
Calculation: Long base stop = minimum of latest confirmed pivot low, if available, and close minus ATR times stop multiplier; use the latter alone when no pivot low is available. Short base stop = maximum of latest confirmed pivot high, if available, and close plus ATR times stop multiplier; use the latter alone when no pivot high is available.
Calculation: Long live risk = maximum of entry price minus current long base stop and minimum price increment. Short live risk = maximum of current short base stop minus entry price and minimum price increment. Recalculate base stops, live risk, targets, and trailing readiness on each bar; trailing readiness is not persistent.
Calculation: Long stop = if high >= entry price plus long live risk times trail activation multiplier, maximum of long base stop and close minus ATR times trail multiplier; otherwise long base stop. Short stop = if low <= entry price minus short live risk times trail activation multiplier, minimum of short base stop and close plus ATR times trail multiplier; otherwise short base stop. Stop and target orders calculated at a bar close apply from the next available tick.
Long: locked regime = bullish
Short: locked regime = bearish
Long: weave bias = bullish
Short: weave bias = bearish
Long: geometry bias = bullish
Short: geometry bias = bearish
Long: bullish structure break = true
Short: bearish structure break = true
Long: recent bullish divergence = true
Short: recent bearish divergence = true
Long: long entry stack = true
Short: short entry stack = true
Exit: long, low <= active long stop OR high >= active long target, where long target = entry price plus long live risk times reward multiplier
Exit: short, high >= active short stop OR low <= active short target, where short target = entry price minus short live risk times reward multiplier
Exit: long, locked regime = bearish OR weave bias = bearish
Exit: short, locked regime = bullish OR weave bias = bullish