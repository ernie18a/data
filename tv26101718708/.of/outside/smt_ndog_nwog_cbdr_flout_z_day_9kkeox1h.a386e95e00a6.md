Only one component uses data from outside the traded instrument: swing divergence against a correlated reference instrument. It runs on the traded instrument's timeframe, with the reference series aligned bar-for-bar. All other components (daily range, opening gaps, dealer ranges, projections) use only the traded instrument and give no trade decisions.

Swing detection: on each instrument separately, a swing high is a bar whose high is the highest, and a swing low is a bar whose low is the lowest, within an equal number of bars on each side. A swing is confirmed only after that many bars have passed on the right side. Keep the previous confirmed swing high and swing low of each instrument. Compare a new swing against the previous one before overwriting it.

Bearish divergence, which means go short: on a bar where both instruments confirm a swing high at the same time, compare each against its own previous swing high. If one instrument made a higher high and the other made a lower high, signal short. This applies whichever instrument is the higher one. A new high in one that the other fails to confirm suggests a false breakout.

Bullish divergence, which means go long: on a bar where both instruments confirm a swing low at the same time, compare each against its own previous swing low. If one instrument made a lower low and the other made a higher low, signal long. This applies whichever instrument is the lower one. A sweep of lows in one that the other fails to confirm suggests a false breakdown.

The signal is evaluated once, at the bar where both swings are confirmed, so it lags the actual swing by the confirmation window. If one instrument has no new swing on that bar, there is no signal.

No exit rule or stop is defined. A position is closed or reversed only by the opposite divergence signal. If no signal fires, take no action.