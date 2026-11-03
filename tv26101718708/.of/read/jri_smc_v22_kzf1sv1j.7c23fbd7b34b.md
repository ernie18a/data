Calculation: Confirmed swing high or low = a pivot high or low with the same parameterized number of bars on each side; recognize it on the bar that confirms it.
Calculation: Bullish structure = the latest three confirmed swing highs are strictly increasing and the latest three confirmed swing lows are strictly increasing; bearish structure = both sequences are strictly decreasing.
Calculation: Upward break = close > the second-latest confirmed swing high AND previous close <= that same high; downward break = close < the second-latest confirmed swing low AND previous close >= that same low.
Calculation: Upward retest = after an upward break, including on the break bar, low <= the current second-latest confirmed swing high multiplied by one plus a buffer AND close > that high; allow only the first such retest after each upward break. Downward retest = after a downward break, including on the break bar, high >= the current second-latest confirmed swing low multiplied by one minus the buffer AND close < that low; allow only the first such retest after each downward break.
Calculation: Supply and demand zones = for each confirmed swing high or low respectively, find the first existing same-side zone containing the pivot and increment its count; otherwise create a zone with bounds equal to the pivot multiplied by one minus and one plus a buffer and count one. A zone is confirmed when its count reaches a threshold; its bounds remain unchanged.
Calculation: Upper liquidity sweep = high > the highest high over a lookback ending on the previous bar AND close < that highest high; lower liquidity sweep = low < the lowest low over the same lookback ending on the previous bar AND close > that lowest low.
Calculation: Bullish imbalance = low > high two bars ago AND previous close > high two bars ago; bearish imbalance = high < low two bars ago AND previous close < low two bars ago.
Calculation: Confirmation score = sum one point for each true condition: bullish or bearish structure; upper or lower liquidity sweep; absolute candle body > a multiplier times its moving average; bullish or bearish imbalance; upward or downward break; upward or downward retest; RSI > an upper threshold with bullish structure OR RSI < a lower threshold with bearish structure; close inside any confirmed supply or demand zone; ATR multiplied by the risk multiplier > zero.
Calculation: Signal state = flat initially; set it to the signal side on a signal and reset it to flat when the confirmation score falls below the signal threshold minus an offset. Track the last signal bar separately for each side.
Calculation: Trade lock = locked after a threshold of consecutive tracked stop losses; reset the consecutive-loss count and unlock after a tracked target win or at the start of a new higher-timeframe calendar period.
Calculation: Tracked risk distance = ATR on the entry bar multiplied by a risk multiplier and a point-value multiplier; use a different risk multiplier for the designated chart-timeframe group. A tracked trade enters at the open of the bar after a signal if no tracked trade is active; evaluate its stop before its target on each bar, including the entry bar.
Long: A newly confirmed swing high > the preceding confirmed swing high.
Short: A newly confirmed swing high <= the preceding confirmed swing high.
Long: A newly confirmed swing low > the preceding confirmed swing low.
Short: A newly confirmed swing low <= the preceding confirmed swing low.
Long: Bullish structure = true.
Short: Bearish structure = true.
Long: Upward break = true.
Short: Downward break = true.
Long: Lower liquidity sweep = true.
Short: Upper liquidity sweep = true.
Long: A confirmed demand zone count >= the confirmation threshold.
Short: A confirmed supply zone count >= the confirmation threshold.
Long: Close > VWAP of typical price anchored to the current, still-forming higher-timeframe calendar period.
Short: Close <= VWAP of typical price anchored to the current, still-forming higher-timeframe calendar period.
Long: Shorter-period close EMA > longer-period close EMA.
Short: Shorter-period close EMA <= longer-period close EMA.
Long: RSI > its midpoint.
Short: RSI <= its midpoint.
Long: Confirmation score >= its threshold AND bullish structure = true AND upward break = true AND signal state = flat AND trade lock = unlocked AND the optional session filter passes AND bars since the last long signal > the cooldown or no previous long signal exists.
Short: Confirmation score >= its threshold AND bearish structure = true AND downward break = true AND signal state = flat AND trade lock = unlocked AND the optional session filter passes AND bars since the last short signal > the cooldown or no previous short signal exists.
Exit: Long, low <= entry price minus tracked risk distance OR high >= entry price plus a target multiplier times tracked risk distance.
Exit: Short, high >= entry price plus tracked risk distance OR low <= entry price minus a target multiplier times tracked risk distance.