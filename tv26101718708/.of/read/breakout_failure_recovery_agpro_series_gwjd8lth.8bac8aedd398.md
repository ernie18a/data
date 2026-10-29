Calculation: Prior range high/low = highest high / lowest low over a lookback of prior bars, excluding the current bar
Calculation: Breakout probe distance = ATR × probe multiplier
Calculation: Upper failed breakout = current high exceeds prior range high by the probe distance and current close is strictly inside the prior range by at least the required inside depth
Calculation: Lower failed breakout = current low exceeds prior range low by the probe distance and current close is strictly inside the prior range by at least the required inside depth
Calculation: For an upper failure, reclaim level = failed upper boundary + probe distance; for a lower failure, reclaim level = failed lower boundary − probe distance
Calculation: Failure confirmed = an active failure has not reclaimed, and either (after its first bar) price retests the failed boundary and closes beyond it by more than the shelf half-width in the failure direction, or price closes beyond the saved range midpoint in the failure direction at least two bars after the failure
Long: lower failed breakout OR active upper failure and close ≥ reclaim level OR active lower failure and failure confirmed
Short: upper failed breakout OR active lower failure and close ≤ reclaim level OR active upper failure and failure confirmed