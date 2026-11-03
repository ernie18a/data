Calculation: Confirmed swing high or low = a pivot high or low with equal configurable numbers of bars on each side; recognize it only when the right-hand bars have completed.
Calculation: Bullish structure = each of the three latest confirmed swing highs and each of the three latest confirmed swing lows is higher than its predecessor; bearish structure = each is lower than its predecessor.
Calculation: Upward structure break = close > the second-latest confirmed swing high AND previous close <= that same current level; downward structure break = close < the second-latest confirmed swing low AND previous close >= that same current level.
Calculation: Upward retest = after an upward structure break, low <= the current second-latest swing high multiplied by one plus a buffer AND close > that swing high; downward retest = after a downward structure break, high >= the current second-latest swing low multiplied by one minus a buffer AND close < that swing low. Set each direction's pending state on its break and clear it on its first retest, including a retest on the break bar.
Calculation: Supply and demand zones = for each confirmed swing high or low respectively, find the first existing same-side zone containing the swing price and increment its count; otherwise create a zone bounded by that price multiplied by one minus and one plus a buffer, with count initially one. A zone is confirmed when its count reaches a minimum.
Calculation: Confirmation score = count the true conditions among: bullish OR bearish structure; high > the prior lookback high AND close < that high OR low < the prior lookback low AND close > that low; absolute candle body > a multiple of its SMA; low > high at a prior offset AND previous close > that high OR high < low at that offset AND previous close < that low; upward OR downward structure break; upward OR downward retest; RSI > an upper threshold AND bullish structure OR RSI < a lower threshold AND bearish structure; close inside a confirmed supply OR demand zone; ATR multiplied by the risk multiplier and point-value adjustment > zero.
Calculation: Signal state = initially inactive; set active on either entry signal and clear when confirmation score < the entry threshold minus a configurable offset. Track the last signal bar separately for each direction.
Calculation: Trade tracker = after an entry signal, if no tracked trade is active, enter at the next bar's open and fix risk distance as that bar's ATR multiplied by the point-value adjustment and risk multiplier. Close the tracked trade on its stop or full target, with the stop taking priority if both are touched on the same bar. Count consecutive tracked stops, reset the count on a full-target win or a change of day, and block signals when the count reaches the loss limit until a win or day change resets it.
Long: A newly confirmed swing high > the preceding confirmed swing high OR a newly confirmed swing low > the preceding confirmed swing low.
Short: A newly confirmed swing high <= the preceding confirmed swing high OR a newly confirmed swing low <= the preceding confirmed swing low.
Long: Bullish structure.
Short: Bearish structure.
Long: Upward structure break.
Short: Downward structure break.
Long: Low < the lowest low of the preceding lookback bars AND close > that lowest low.
Short: High > the highest high of the preceding lookback bars AND close < that highest high.
Long: A demand zone count >= the confirmation minimum.
Short: A supply zone count >= the confirmation minimum.
Long: Shorter-period EMA of close > longer-period EMA of close.
Short: Shorter-period EMA of close <= longer-period EMA of close.
Long: RSI > its bullish threshold.
Short: RSI <= its bullish threshold.
Long: Confirmation score >= entry threshold AND bullish structure AND upward structure break AND signal state inactive AND consecutive tracked stops < loss limit AND (session filter disabled OR datetime within an enabled session on an enabled weekday in the session timezone) AND (no prior long signal OR bars since prior long signal > cooldown). The cooldown and risk multiplier can depend on chart timeframe.
Short: Confirmation score >= entry threshold AND bearish structure AND downward structure break AND signal state inactive AND consecutive tracked stops < loss limit AND (session filter disabled OR datetime within an enabled session on an enabled weekday in the session timezone) AND (no prior short signal OR bars since prior short signal > cooldown). The cooldown and risk multiplier can depend on chart timeframe.
Exit: long, low <= entry price minus fixed risk distance OR high >= entry price plus full-target multiple of fixed risk distance.
Exit: short, high >= entry price plus fixed risk distance OR low <= entry price minus full-target multiple of fixed risk distance.
Exit: long, high >= entry price plus partial-target multiple of fixed risk distance.
Exit: short, low <= entry price minus partial-target multiple of fixed risk distance.
Calculation: After price reaches an intermediate target at a multiple of risk distance greater than the partial-target multiple and less than the full-target multiple, move the displayed stop to entry price; the tracked stop remains at its original level.
Exit: long, after the intermediate target is reached, low <= entry price.
Exit: short, after the intermediate target is reached, high >= entry price.