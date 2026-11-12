Calculation: RVOL = volume / EMA of capped volume, where each bar's volume is capped at a multiple (>1) of the prior bar's EMA of raw volume; both EMAs use the same lookback
Calculation: strong volume = RVOL >= high threshold (threshold > 1); weak volume = RVOL <= low threshold (threshold < 1)
Calculation: bull close strength = (close-low)/(high-low), 0.5 if high=low; bear close strength = (high-close)/(high-low), 0.5 if high=low; strong bull/bear close = strength >= a threshold
Calculation: fast, mid, slow EMA of close, with fast lookback < mid lookback < slow lookback
Calculation: bull bias = close > slow EMA AND fast EMA > mid EMA AND mid EMA > slow EMA AND mid EMA > mid EMA of previous bar; bear bias = close < slow EMA AND fast EMA < mid EMA AND mid EMA < slow EMA AND mid EMA < mid EMA of previous bar
Calculation: prior high = highest high of the previous N bars excluding the current bar; prior low = lowest low of the previous N bars excluding the current bar
Long: close > prior high AND close > open AND strong bull close AND strong volume
Long: bull bias AND low <= fast EMA AND close > fast EMA AND close > mid EMA AND close > open AND strong bull close AND NOT weak volume
Long: bull bias AND low <= fast EMA AND close >= mid EMA AND close < open AND NOT strong volume
Short: close < prior low AND close < open AND strong bear close AND strong volume
Short: bear bias AND high >= fast EMA AND close < fast EMA AND close < mid EMA AND close < open AND strong bear close AND NOT weak volume
Short: bear bias AND high >= fast EMA AND close <= mid EMA AND close > open AND NOT strong volume
Exit: long, (bull bias AND low <= fast EMA AND close >= mid EMA AND close < open AND strong bear close AND strong volume) OR (high > prior high AND (weak volume OR NOT strong bull close))
Exit: short, (bear bias AND high >= fast EMA AND close <= mid EMA AND close > open AND strong bull close AND strong volume) OR (low < prior low AND (weak volume OR NOT strong bear close))