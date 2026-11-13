Trade the chart instrument using a second, correlated instrument on the same timeframe. Two independent signal types, both producing long or short entries. There is no exit logic.

1. SMT divergence (swing-based).
Define a swing high as a bar whose high is the highest within a fixed number of bars on each side, and a swing low as the mirror. A swing is only confirmed after that many bars have passed, so signals fire on the confirmation bar, not the swing bar. Detect swings on both instruments with the same rule. For each instrument, keep the two most recent confirmed swing highs and the two most recent confirmed swing lows, plus the bar position of the latest one of each.
- Short signal: when a new swing high is confirmed on the chart instrument, check that the correlated instrument has at least two swing highs on record and that its latest swing high sits within a maximum bar distance of this one (the sync window). If so, and the chart instrument's new swing high is higher than its previous swing high while the correlated instrument's latest swing high is lower than or equal to its previous one, the chart instrument made a new high that the correlated one did not confirm. Go short on that bar.
- Long signal: the mirror. When a new swing low is confirmed on the chart instrument, with the correlated instrument having at least two swing lows and its latest within the sync window, and the chart instrument's new swing low is lower than its previous one while the correlated instrument's latest swing low is higher than or equal to its previous one, go long on that bar.
Update the correlated instrument's swing records before evaluating the chart instrument's swing on the same bar.

2. Candle-direction divergence (per bar).
On each closed bar compare the candle direction (close versus open) of the two instruments.
- Long signal: the chart instrument's candle is bullish while the correlated instrument's candle is bearish.
- Short signal: the chart instrument's candle is bearish while the correlated instrument's candle is bullish.
A bar with no direction (close equal to open) on either instrument triggers nothing.

Other elements of the source (fair value gaps, range high/low lines, premium/discount zones, displacement highlighting) use only the chart instrument's own data and are not part of the decision logic.