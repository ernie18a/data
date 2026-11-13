Decision logic: a divergence-based entry signal between the traded instrument and one correlated reference instrument (an index-like peer). There is no exit rule. Evaluate on every bar of the traded instrument's chart timeframe, and fetch the reference instrument's data at the same timeframe without look-ahead.

1. Swing pivots. For both instruments, detect confirmed swing highs and swing lows. A swing high is a bar whose high is the highest among a fixed number of bars on each side. A swing low is a bar whose low is the lowest among the same window. Confirmation comes only after that many bars have closed to the right of the pivot. Compute the reference instrument's pivots with the same window and the same confirmation delay.

2. State. Keep these four values for each instrument.
- Traded instrument: its two most recent swing-high values, and its two most recent swing-low values.
- Reference instrument: its two most recent swing-high values, and its two most recent swing-low values.
- Update the reference instrument's state first on each bar. When it confirms a new pivot, shift the older value out and store the new one. Also record the bar index at which that confirmation arrived, separately for highs and for lows.
- The traded and reference pivot sequences are tracked independently. They are not matched by timestamp.

3. Short signal (bearish divergence). Evaluate it only on a bar where the traded instrument confirms a new swing high, after shifting that instrument's two swing-high values. Go short when all of the following hold.
- Both of the traded instrument's last two swing highs and both of the reference instrument's last two swing highs exist.
- The traded instrument's newest swing high is above its previous swing high (a higher high).
- The reference instrument's newest swing high is below its previous swing high (a lower high), so it fails to confirm.
- The reference instrument's most recent swing-high confirmation happened no more than a maximum number of bars ago, so the comparison is recent.

4. Long signal (bullish divergence). This is the mirror image, evaluated only on a bar where the traded instrument confirms a new swing low. Go long when all of the following hold.
- Both instruments have their last two swing lows.
- The traded instrument's newest swing low is below its previous swing low (a lower low).
- The reference instrument's newest swing low is above its previous swing low (a higher low).
- The reference instrument's most recent swing-low confirmation was no more than the same maximum number of bars ago.

5. Timing. The signal fires on the confirmation bar, which is the pivot's delay after the pivot bar itself. It is a one-bar event and not a persistent state. Because no exit logic is defined, closing or reversing a position is left to the implementer, for example an opposite signal.