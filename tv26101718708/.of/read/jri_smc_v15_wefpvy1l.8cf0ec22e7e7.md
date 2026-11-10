Calculation: Confirmed swing high/low = a high/low with the same number of bars on each side required to confirm it as a pivot; make it available on its confirmation bar.
Calculation: Supply/demand zones = for each confirmed swing high/low, find the first existing same-side zone containing the pivot and increment its pivot count; otherwise create a zone centered on the pivot with fixed proportional upper and lower bounds and count one. A zone is eligible when its count reaches a threshold.
Calculation: Upward/downward structure break = close crosses above/below the second most recent confirmed swing high/low, comparing both current and previous close with the current pivot level.
Calculation: Support/resistance retest = after an upward/downward structure break, respectively, the first bar whose low/high reaches the current second most recent swing high/low plus/minus a proportional buffer and whose close remains above/below that level; the break bar can also be the retest bar.
Calculation: Long score = count of these conditions: latest confirmed swing high and low are each above their respective preceding pivots; close is inside an eligible demand zone; upward structure break; support retest; close above calendar-day-reset VWAP of typical price; shorter EMA of close above longer EMA; RSI above its midpoint.
Calculation: Short score = count of these conditions: latest confirmed swing high and low are each below their respective preceding pivots; close is inside an eligible supply zone; downward structure break; resistance retest; close below calendar-day-reset VWAP of typical price; shorter EMA of close below longer EMA; RSI below its midpoint.
Calculation: Signal state = both sides start inactive; a buy/sell signal activates its side and deactivates the other; an active side becomes inactive when its score falls below the signal threshold minus a margin. Each side has its own cooldown measured from its last signal, with a longer cooldown on shorter chart timeframes. Signals are locked after a threshold number of consecutive simulated stop losses; reset the loss count and lock on a simulated target hit or calendar-day change. Simulated trades enter at the next bar's open only if no simulated trade is active, and use entry-bar ATR to fix an entry-price-based stop and a farther target at a fixed multiple of stop distance. Check the stop before the target, including on the entry bar.
Calculation: Signal-derived levels = for a buy/sell signal, use signal-bar high/low as the reference entry and signal-bar low minus/high plus signal-bar ATR times a multiplier as the stop; targets are fixed multiples of the reference-entry-to-stop distance beyond the reference entry. The first target is nearer than the final target, and the intermediate target triggers moving the stop to the reference entry.
Long: Confirmed swing high is above the preceding confirmed swing high OR confirmed swing low is above the preceding confirmed swing low.
Short: Confirmed swing high is at or below the preceding confirmed swing high OR confirmed swing low is at or below the preceding confirmed swing low.
Long: Latest confirmed swing high and low are each above their respective preceding pivots.
Short: Latest confirmed swing high and low are each below their respective preceding pivots.
Long: Close is above open AND absolute candle body is above a multiple of its moving average.
Short: Close is below open AND absolute candle body is above a multiple of its moving average.
Long: Upward structure break.
Short: Downward structure break.
Long: Close is inside an eligible demand zone AND the previous bar's close was not inside any eligible demand zone as evaluated on that bar.
Short: Close is inside an eligible supply zone AND the previous bar's close was not inside any eligible supply zone as evaluated on that bar.
Long: Low is below the lowest low of the preceding lookback AND close is above that lowest low.
Short: High is above the highest high of the preceding lookback AND close is below that highest high.
Long: Shorter EMA of close is above longer EMA.
Short: Shorter EMA of close is at or below longer EMA.
Long: RSI is above its midpoint.
Short: RSI is at or below its midpoint.
Long: Long score is at least the signal threshold AND both signal sides are inactive AND the loss lock is inactive AND the long-side cooldown has elapsed or there has been no prior long signal.
Short: Short score is at least the signal threshold AND both signal sides are inactive AND the loss lock is inactive AND the short-side cooldown has elapsed or there has been no prior short signal.
Exit: long, low is at or below the simulated entry-price-based stop OR high is at or above the simulated final target, with the stop taking precedence if both are reached.
Exit: short, high is at or above the simulated entry-price-based stop OR low is at or below the simulated final target, with the stop taking precedence if both are reached.
Exit: long, high is at or above the signal-derived first target for a partial exit OR high is at or above the signal-derived final target for a full exit OR low is at or below the signal-derived stop, moved to the reference entry after the intermediate target is reached.
Exit: short, low is at or below the signal-derived first target for a partial exit OR low is at or below the signal-derived final target for a full exit OR high is at or above the signal-derived stop, moved to the reference entry after the intermediate target is reached.