Calculation: Confirmed swing high/low = a pivot high/low confirmed after an equal number of preceding and following chart bars; retain confirmed pivots in confirmation order.
Calculation: Demand/supply zones = for each confirmed swing low/high, increment the count of the first existing same-kind zone containing the pivot; otherwise create a zone centered on the pivot with parameterized proportional upper and lower bounds and count one. A zone is confirmed when its count reaches a threshold. A close is in a zone when it is within both bounds, inclusive.
Calculation: Bullish/bearish structure break = close crosses above/below the second-most-recent confirmed swing high/low, comparing both current and previous close with the current level.
Calculation: Bullish/bearish retest = after the corresponding structure break, the first bar whose low/high reaches the current second-most-recent swing high/low within a proportional buffer and whose close is above/below that level. Set the pending state before checking the break bar itself; clear it after a retest. The level can change while the state is pending.
Calculation: Bullish score = count of: latest swing high and low both greater than their respective previous pivots; close in a confirmed demand zone; bullish structure break; bullish retest; close above calendar-day-anchored VWAP of typical price; shorter EMA above longer EMA; RSI above its midpoint. Bearish score = count of the corresponding inverse comparisons, using a confirmed supply zone.
Calculation: Signal state = compute both signals from the state at the start of the bar. A signal requires neither side to be active and its own side's previous signal to be more than a parameterized cooldown ago, or absent. After signals, activate their sides; then deactivate an active side when its score falls below the signal threshold minus a parameterized margin. A signal resets the consecutive-loss counter and trading lock. Subsequently, an active side whose score falls below a separate loss threshold is deactivated and increments the counter; lock trading when the counter reaches its threshold. Use the chart-timeframe-dependent cooldown parameter.
Calculation: Initial risk = entry-bar high minus entry-bar low plus entry-bar ATR times a chart-timeframe-dependent multiplier. Long entry and initial stop are the entry-bar high and low minus that ATR buffer; short entry and initial stop are the entry-bar low and high plus that buffer. Set partial and full targets at parameterized increasing multiples of initial risk from entry, and move the stop to entry after price reaches an intermediate target.
Long: A newly confirmed swing high is greater than the previous confirmed swing high OR a newly confirmed swing low is greater than the previous confirmed swing low.
Short: A newly confirmed swing high is less than or equal to the previous confirmed swing high OR a newly confirmed swing low is less than or equal to the previous confirmed swing low.
Long: The latest confirmed swing high and swing low are both greater than their respective previous pivots.
Short: The latest confirmed swing high and swing low are both less than their respective previous pivots.
Long: Close is greater than open AND absolute candle body is greater than a parameterized multiple of its moving average.
Short: Close is less than open AND absolute candle body is greater than a parameterized multiple of its moving average.
Long: A bullish structure break occurs.
Short: A bearish structure break occurs.
Long: Close is in a confirmed demand zone AND the previous close was not in a confirmed demand zone as evaluated on the previous bar.
Short: Close is in a confirmed supply zone AND the previous close was not in a confirmed supply zone as evaluated on the previous bar.
Long: Low is below the preceding lookback's lowest low AND close is above that lowest low.
Short: High is above the preceding lookback's highest high AND close is below that highest high.
Long: Bullish score is at least the signal threshold AND signal state permits a long signal AND trading lock is off.
Short: Bearish score is at least the signal threshold AND signal state permits a short signal AND trading lock is off.
Exit: Long, low is at or below the current stop OR high reaches the full target.
Exit: Short, high is at or above the current stop OR low reaches the full target.
Exit: Long, high first reaches the partial target; close a parameterized fraction of the position.
Exit: Short, low first reaches the partial target; close a parameterized fraction of the position.