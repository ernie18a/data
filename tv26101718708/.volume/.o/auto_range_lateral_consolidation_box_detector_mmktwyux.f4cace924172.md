Calculation: Standard range high/low = highest high and lowest low over the longer range lookback, using completed bars before the current bar
Calculation: Shelf high/low = highest high and lowest low over the shorter range lookback, using completed bars before the current bar
Calculation: Range midpoint = (range high + range low) / 2; range width % = (range high - range low) / midpoint
Calculation: Close containment % = percentage of completed bars in the range lookback whose closes are between that range’s high and low
Calculation: Shelf upper-half % = percentage of completed bars in the shelf lookback whose closes are at or above the shelf midpoint
Calculation: Prior advance % = (range high - lowest low over the prior-move lookback ending before the range began) / that lowest low × 100; the prior-move lookback is longer than either range lookback
Calculation: ADR % = moving average of (high - low) / close × 100
Calculation: Standard range qualifies = close containment % meets its minimum AND range width % ≤ ADR % × standard-width limit AND prior close satisfies the trend filter AND (prior advance % meets its minimum OR prior-advance filter is disabled) AND (range’s average volume ≤ prior average volume × volume limit OR volume filter is disabled) AND (prior RSI is within its limits OR RSI filter is disabled); trend filter = (above-200-SMA filter disabled OR prior close > prior long-term SMA) AND (prior short-term EMA ≥ prior medium-term EMA OR prior close ≥ prior medium-term EMA)
Calculation: Shelf qualifies = close containment % meets its minimum AND shelf upper-half % ≥ its minimum AND shelf width % ≤ ADR % × tighter shelf-width limit AND the same trend, prior-advance, volume, and RSI filters as the standard range
Calculation: Active range = qualifying shelf if one exists; otherwise qualifying standard range if one exists; otherwise none
Long: Active range exists AND current close > active range high
Short: Active range exists AND current close < active range low