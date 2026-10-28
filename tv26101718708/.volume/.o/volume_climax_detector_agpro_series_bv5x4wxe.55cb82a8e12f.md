Calculation: Volume Z-score = (current volume − rolling mean volume) / rolling standard deviation of volume
Calculation: Relative volume = current volume / rolling mean volume
Calculation: Spread ratio = (high − low) / rolling mean of (high − low)
Calculation: Close location = (close − low) / (high − low); use 0.5 when high = low
Calculation: Body fraction = |close − open| / (high − low); use 0 when high = low
Calculation: Upper-close = close location ≥ sensitivity threshold; lower-close = close location ≤ 1 − sensitivity threshold
Calculation: Trend = close above/below EMA, with EMA slope over a prior-bar interval normalized by ATR; bullish/bearish trend requires slope above/below the sensitivity threshold
Calculation: Event direction = +1 if upper-close, −1 if lower-close, otherwise +1 if close ≥ open and −1 otherwise
Calculation: Volume spike = Volume Z-score ≥ sensitivity threshold OR relative volume ≥ sensitivity threshold
Calculation: Qualified bar = volume spike AND spread ratio ≥ sensitivity threshold AND (upper-close OR lower-close OR body fraction ≥ threshold)
Calculation: Event score = rounded, capped sum of relative-volume score, spread-ratio score, close-quality score, body-fraction score, and trend score; favor trend-aligned event direction over opposing direction
Long: confirmed bar AND qualified bar AND Event direction = −1 AND event score ≥ minimum score AND (no event in its follow-through window) AND (no prior event within cooldown
Short: confirmed bar AND qualified bar AND Event direction = +1 AND event score ≥ minimum score AND (no event in its follow-through window) AND (no prior event within cooldown