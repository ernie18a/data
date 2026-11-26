Calculation: Confirmed swings = pivot highs and lows confirmed after the configured strength of bars on each side; higher/lower labels compare each pivot with the previous pivot of the same type.
Calculation: Structure state = direction of the latest break of an unbroken confirmed swing high or low, initially neutral; an upward break uses close or high and a downward break uses close or low, according to the configured break source; retain each broken level.
Calculation: Equal-high/equal-low zones = zones formed by confirmed pivot highs or lows within an ATR-based tolerance; merge overlapping zones, discard stale pivot candidates, retain the configured maximum number of zones, and remove an equal-high zone when high exceeds its upper edge or an equal-low zone when low falls below its lower edge.
Calculation: Long-zone touch = the chart bar intersects an active equal-low zone, the latest upward-broken structure level, or the long EMA, within the configured ATR-based tolerance; short-zone touch uses an equal-high zone, the latest downward-broken level, or the long EMA.
Calculation: Intrabar buy volume = sum of selected-volume-source volume on T1 bars within each chart bar when close exceeds open, plus half the volume when close equals open; use available still-forming T1 data in real time.
Calculation: Intrabar sell volume = sum of selected-volume-source volume on T1 bars within each chart bar when close is below open, plus half the volume when close equals open; use available still-forming T1 data in real time.
Calculation: Delta = intrabar buy volume minus intrabar sell volume.
Calculation: CVD = Delta accumulated on chart bars, reset at the configured reset boundary.
Calculation: Relative volume = total intrabar volume divided by its configured average or median over the configured lookback.
Calculation: Buy bubble = buy share is at least half, dominant-side share and relative volume meet their configured thresholds, and the bubble passes the configured strongest-per-window rule; compare with the last bubble in the configured side group and retain a nearby current bubble only when its relative volume is greater.
Calculation: Sell bubble = buy share is below half, dominant-side share and relative volume meet their configured thresholds, and the bubble passes the configured strongest-per-window rule; compare with the last bubble in the configured side group and retain a nearby current bubble only when its relative volume is greater.
Calculation: Bullish CVD divergence = a confirmed price pivot low is lower than the preceding confirmed pivot low while CVD at that pivot is higher than CVD at the preceding pivot low, with both pivots in the same CVD reset period.
Calculation: Bearish CVD divergence = a confirmed price pivot high is higher than the preceding confirmed pivot high while CVD at that pivot is lower than CVD at the preceding pivot high, with both pivots in the same CVD reset period.
Calculation: Timeframe trend on T2, T3, T4, T5, T6, or T7 = bullish when the configured method is EMA(fast) >= EMA(slow), upward Supertrend, or close >= long EMA; otherwise bearish. Compute on bars of that timeframe and read on chart bars, using its last completed bar historically and still-forming bar in real time.
Calculation: Bias = sum of the six higher-timeframe trend values, with bullish equal to +1 and bearish equal to -1.
Calculation: Sideways = the prior configured lookback range width is no greater than the configured ATR multiple, or cloud crosses within the configured lookback meet the configured count. Range breakout up/down = the prior bar was sideways and the current close is above/below the prior lookback high/low.
Calculation: Long A score = one point each for bias meeting the configured bullish threshold, close above long EMA, bullish structure state, long-zone touch within the A/B lookback, buy bubble within that lookback, an up candle while candle trend is down within that lookback, positive short-lookback Delta sum or bullish CVD divergence within that lookback, and rising fast average.
Calculation: Short A score = one point each for bias meeting the configured bearish threshold, close below long EMA, bearish structure state, short-zone touch within the A/B lookback, sell bubble within that lookback, a down candle while candle trend is up within that lookback, negative short-lookback Delta sum or bearish CVD divergence within that lookback, and falling fast average.
Calculation: Long B score = one point each for buy bubble within the A/B lookback, bullish CVD divergence within that lookback, bullish CHoCH within that lookback, rising fast average, and positive short-lookback Delta sum.
Calculation: Short B score = one point each for sell bubble within the A/B lookback, bearish CVD divergence within that lookback, bearish CHoCH within that lookback, falling fast average, and negative short-lookback Delta sum.
Calculation: Long C score = one point each for bias meeting the configured bullish threshold, bullish structure state, long-zone touch within the C lookback, buy bubble within that lookback, and positive short-lookback Delta sum or bullish CVD divergence within that lookback.
Calculation: Short C score = one point each for bias meeting the configured bearish threshold, bearish structure state, short-zone touch within the C lookback, sell bubble within that lookback, and negative short-lookback Delta sum or bearish CVD divergence within that lookback.
Calculation: Long S score = one point each for positive bias, buy bubble within the C lookback, positive short-lookback Delta sum or bullish CVD divergence within that lookback, rising fast average, and break-bar buy share and relative volume meeting their separate S thresholds.
Calculation: Short S score = one point each for negative bias, sell bubble within the C lookback, negative short-lookback Delta sum or bearish CVD divergence within that lookback, falling fast average, and break-bar sell share and relative volume meeting their separate S thresholds.
Long: EMA(fast) >= EMA(slow) (green cloud)
Short: EMA(fast) < EMA(slow) (red cloud)
Long: EMA(fast) crosses above EMA(slow)
Short: EMA(fast) crosses below EMA(slow)
Long: configured candle-trend method is bullish: EMA(fast) >= EMA(slow) or close >= long EMA
Short: configured candle-trend method is bearish: EMA(fast) < EMA(slow) or close < long EMA
Long: candle-trend method is bearish AND close > open
Short: candle-trend method is bullish AND close < open
Long: selected fast average (Hull MA or Zero-lag EMA) >= its prior value
Short: selected fast average < its prior value
Long: selected fast average turns from falling to rising
Short: selected fast average turns from rising to falling
Long: confirmed swing high exceeds the preceding confirmed swing high OR confirmed swing low exceeds the preceding confirmed swing low
Short: confirmed swing high is below the preceding confirmed swing high OR confirmed swing low is below the preceding confirmed swing low
Long: an unbroken confirmed swing high breaks upward while prior structure state is not bearish (bullish BOS)
Short: an unbroken confirmed swing low breaks downward while prior structure state is not bullish (bearish BOS)
Long: an unbroken confirmed swing high breaks upward while prior structure state is bearish (bullish CHoCH)
Short: an unbroken confirmed swing low breaks downward while prior structure state is bullish (bearish CHoCH)
Long: any of the six higher-timeframe trends is bullish
Short: any of the six higher-timeframe trends is bearish
Long: bias meets the configured positive display threshold
Short: bias meets the configured negative display threshold
Long: Delta >= 0
Short: Delta < 0
Long: CVD >= its prior chart-bar value
Short: CVD < its prior chart-bar value
Long: buy bubble
Short: sell bubble
Long: bullish CVD divergence
Short: bearish CVD divergence
Long: range breakout up
Short: range breakout down
Long: EMA(fast) crosses above EMA(slow) AND Long A score >= minimum A score AND the A/B range gate permits long
Short: EMA(fast) crosses below EMA(slow) AND Short A score >= minimum A score AND the A/B range gate permits short
Long: EMA(fast) crosses above EMA(slow) AND Long A score >= strong-A alert threshold AND the A/B range gate permits long
Short: EMA(fast) crosses below EMA(slow) AND Short A score >= strong-A alert threshold AND the A/B range gate permits short
Long: B is enabled AND EMA(fast) crosses above EMA(slow) AND no A long signal AND an equal-low zone was swept within the A/B lookback AND Long B score >= minimum B score AND the A/B range gate permits long
Short: B is enabled AND EMA(fast) crosses below EMA(slow) AND no A short signal AND an equal-high zone was swept within the A/B lookback AND Short B score >= minimum B score AND the A/B range gate permits short
Long: C is enabled AND EMA(fast) >= EMA(slow) AND no upward cloud cross on this bar AND close > long EMA AND low <= EMA(fast) within the C lookback AND (fast average turns up now OR a buy bubble occurs now) AND close > open AND close > EMA(fast) AND the configured C cooldown has elapsed AND no A or B long signal AND Long C score >= minimum C score AND the optional C range gate permits long
Short: C is enabled AND EMA(fast) < EMA(slow) AND no downward cloud cross on this bar AND close < long EMA AND high >= EMA(fast) within the C lookback AND (fast average turns down now OR a sell bubble occurs now) AND close < open AND close < EMA(fast) AND the configured C cooldown has elapsed AND no A or B short signal AND Short C score >= minimum C score AND the optional C range gate permits short
Long: C long signal AND Long C score >= configured C strong-alert threshold
Short: C short signal AND Short C score >= configured C strong-alert threshold
Long: C long signal AND Long C score >= configured high-score alert cutoff
Short: C short signal AND Short C score >= configured high-score alert cutoff
Long: S is enabled AND an upward BOS or CHoCH occurs now AND EMA(fast) >= EMA(slow) AND close > long EMA AND close > open AND the latest confirmed swing low is a higher low, had a long-zone touch in its confirmation window, and is within the configured swing-age limit AND Long S score >= minimum S score AND no A, B, or C long signal
Short: S is enabled AND a downward BOS or CHoCH occurs now AND EMA(fast) < EMA(slow) AND close < long EMA AND close < open AND the latest confirmed swing high is a lower high, had a short-zone touch in its confirmation window, and is within the configured swing-age limit AND Short S score >= minimum S score AND no A, B, or C short signal
Long: R is enabled AND range breakout up AND positive bias AND close > open AND (buy bubble OR buy share and relative volume meet their separate R thresholds) AND no A, B, C, or S long signal
Short: R is enabled AND range breakout down AND negative bias AND close < open AND (sell bubble OR sell share and relative volume meet their separate R thresholds) AND no A, B, C, or S short signal