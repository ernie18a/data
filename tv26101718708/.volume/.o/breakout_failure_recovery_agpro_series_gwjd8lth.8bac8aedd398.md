Calculation: Prior range high/low = highest high / lowest low over the lookback bars before the current bar
Calculation: Probe buffer = ATR × probe-distance parameter
Calculation: Failure event = current bar probes beyond a prior range boundary by more than the probe buffer, then closes strictly inside the range by at least the minimum inside-depth parameter; use only confirmed bars
Calculation: Active failure = most recent failure event, with its direction, boundary, opposite range boundary, range midpoint, and event bar retained until replaced
Calculation: Reclaim level = failed boundary + failure direction × probe buffer (upper failure direction = +1; lower failure direction = −1)
Calculation: Shelf half-width = ATR × shelf-width parameter
Calculation: Failure rejection = after the event bar, price retests/pierces the failed boundary and closes beyond it into the range by more than the shelf half-width
Calculation: Deep failure = after an upper failure, close is below the event range midpoint; after a lower failure, close is above it
Long: lower failure event OR active upper failure and close ≥ reclaim level OR active lower failure, no reclaim, and (failure rejection OR deep failure with age ≥ 2 bars)
Short: upper failure event OR active lower failure and close ≤ reclaim level OR active upper failure, no reclaim, and (failure rejection OR deep failure with age ≥ 2 bars)