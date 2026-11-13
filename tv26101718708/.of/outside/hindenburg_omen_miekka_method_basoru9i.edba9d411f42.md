Bearish breadth-warning framework: while the omen is active, exit longs and/or hold a short on the traded instrument. It has no long-entry logic. Evaluate it once per daily bar using NYSE-wide data from outside the traded instrument.

Inputs (daily): NYSE advancing issues, NYSE declining issues, NYSE count of new 52-week highs, NYSE count of new 52-week lows, and the NYSE Composite index close.

Data guard: if any input is missing on a bar, or advances plus declines is not positive, no condition is true on that bar and no trigger or active signal can occur.

Step 1, breadth base: total = advances + declines. Unchanged issues are excluded.

Step 2, trigger. A trigger occurs on a bar only when both conditions hold on that same bar:
- Condition 1, breadth divergence: new highs divided by total, as a percentage, is at or above a threshold, AND new lows divided by total, as a percentage, is at or above the same threshold. Both extremes must be elevated simultaneously. Do not add a highs-to-lows ratio filter.
- Condition 2, uptrend: the NYSE Composite close is greater than or equal to its close a fixed number of trading days earlier. If that earlier value is unavailable, the condition is false.

Step 3, signal window. A trigger opens a window that lasts a fixed number of trading days. The window includes the trigger bar, and a new trigger restarts it. A bar is in the window if the number of bars since the most recent trigger is at or below the window length. If no trigger has ever occurred, no window exists.

Step 4, McClellan Oscillator gate:
- Compute ratio-adjusted net advances each bar as 1000 * (advances - declines) / (advances + declines).
- Smooth it with a 19-period exponential moving average and a 39-period exponential moving average.
- The oscillator is the 19-period average minus the 39-period average.
- The oscillator is only a gate. It never creates a trigger.

Step 5, decision:
- The omen is ACTIVE on a bar when the bar is inside the signal window AND the oscillator is below zero. This is the bearish state: exit any long position and/or go short the traded instrument.
- If the oscillator is zero or positive inside the window, the omen is deactivated, so the bearish state is off. The window keeps running. If the oscillator turns negative again before the window expires, the omen reactivates.
- Outside any window, there is no bearish signal.
- Closing the short or ending the bearish stance happens when the omen is no longer active: the window expired or the oscillator is non-negative.
- Several triggers in quick succession mean a stronger warning, but the on/off rule is unchanged.