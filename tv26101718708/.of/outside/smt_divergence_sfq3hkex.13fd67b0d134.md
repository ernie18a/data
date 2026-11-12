Trade the chart instrument (A) using a second, correlated reference instrument (B) sampled on the same timeframe. This is an SMT divergence framework. A bearish divergence gives a short signal and a bullish divergence gives a long signal. There is no explicit exit rule.

Setup:
- On both A and B, detect confirmed swing pivots. A swing high is a bar whose high is the highest among N bars on each side. A swing low is the mirror. A pivot is only known after the right-side bars have closed.
- For each instrument, keep the latest two swing highs and latest two swing lows. Store each pivot's price and the bar index of the actual pivot bar, not the confirmation bar.
- A synchronization window is the maximum allowed bar distance between a swing on A and the corresponding swing on B for them to count as the same cycle.

Short signal (bearish SMT). Evaluate on each bar. Fire if any one of these holds:
1. B has just confirmed a swing high on this bar. B's latest swing high is above its previous one (higher high). A's latest swing high is below A's previous one (lower high). The two latest swing-high positions are within the window.
2. A has just confirmed a swing high on this bar. A's latest swing high is above its previous one. B's latest swing high is below B's previous one. The two latest swing-high positions are within the window.
3. A has just confirmed a higher swing high on this bar. B's latest swing high is above its previous one, occurred earlier than A's swing high, and is within the window. B's current close is below that B swing high, meaning B already reversed.

Long signal (bullish SMT) is the exact mirror using swing lows:
1. B has just confirmed a lower low, and A's latest swing low is higher than its previous one (higher low), within the window.
2. A has just confirmed a lower low, and B's latest swing low is higher than its previous one, within the window.
3. A has just confirmed a lower low. B made a lower low earlier, within the window. B's current close is above that B swing low.

Deduplication:
- Emit at most one short signal per A swing high and at most one long signal per A swing low.
- Suppress a signal if A's latest swing high (for short) or swing low (for long) was already used for an earlier signal of the same side.

Actions:
- Go short when a bearish signal fires.
- Go long when a bullish signal fires.
- The source defines no exit, stop or target. Any exit or reversal handling is left to the implementer.