Calculation: Close location = (2 × close − high − low) / (high − low)
Calculation: Delta = EMA of volume × (0.65 × close location + 0.35 × (close − open) / (high − low), using the delta smoothing parameter
Calculation: Delta impulse = short EMA of the change in delta
Calculation: Cumulative delta = cumulative sum of delta
Calculation: Cumulative delta Z-score = z-score of cumulative delta over the longer normalization lookback
Calculation: Impulse Z-score = z-score of delta over the shorter impulse-memory lookback
Calculation: Volume Z-score = z-score of volume over the participation lookback
Calculation: Participation = absolute delta / SMA of absolute delta over the participation lookback
Calculation: Absorption ratio = absolute delta / volume
Calculation: Bullish absorption = confirmed bar AND volume Z-score > threshold AND absorption ratio < threshold AND close > open AND low < previous bar low
Calculation: Bearish absorption = confirmed bar AND volume Z-score > threshold AND absorption ratio < threshold AND close < open AND high > previous bar high
Calculation: Upward vacuum = confirmed bar AND impulse Z-score > threshold AND range Z-score > threshold AND close > short ALMA center AND delta impulse > 0
Calculation: Downward vacuum = confirmed bar AND impulse Z-score < negative threshold AND range Z-score > threshold AND close < short ALMA center AND delta impulse < 0
Calculation: Positive divergence = confirmed bar AND disagreement Z-score < negative threshold AND close > previous bar close AND cumulative delta Z-score > its previous value
Calculation: Negative divergence = confirmed bar AND disagreement Z-score > threshold AND close < previous bar close AND cumulative delta Z-score < its previous value
Calculation: Disagreement = price velocity − delta velocity; price velocity is EMA of close change divided by ATR, delta velocity is EMA of delta change divided by SMA of absolute delta over the impulse-memory lookback
Calculation: Bull score = clamp to 0–100 of weighted sum: short ALMA center > long ALMA center; close > current-bar VWAP; clamped positive impulse Z-score contribution; clamped positive cumulative delta Z-score contribution; upward vacuum; bullish absorption; positive divergence; and clamped participation contribution
Calculation: Bear score = clamp to 0–100 of weighted sum: short ALMA center < long ALMA center; close < current-bar VWAP; clamped negative impulse Z-score contribution; clamped negative cumulative delta Z-score contribution; downward vacuum; bearish absorption; negative divergence; and clamped participation contribution. Use the same contribution weights and limits as the bull score, with directional terms reversed
Calculation: Bull regime = bull score > bear score by more than the regime margin
Calculation: Bear regime = bear score > bull score by more than the regime margin
Long: confirmed bar AND (event cooldown has elapsed AND bull score ≥ event threshold AND bull score > bear score AND short ALMA center > long ALMA center OR ((bullish absorption OR positive divergence) AND bull regime AND no long event))
Short: confirmed bar AND (event cooldown has elapsed AND bear score ≥ event threshold AND bear score > bull score AND short ALMA center < long ALMA center OR ((bearish absorption OR negative divergence) AND bear regime AND no short event))