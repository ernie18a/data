Calculation: Price = (high + low + close) / 3
Calculation: AVWAP = cumulative sum(Price * volume) / cumulative sum(volume), accumulated from the most recent anchor (a recurring session start) and restarted at each anchor, including the anchor bar
Calculation: SD = sqrt(max(cumulative sum(Price^2 * volume) / cumulative sum(volume) - AVWAP^2, 0)), over the same accumulation window as AVWAP
Calculation: LowerBand = AVWAP - k * SD; UpperBand = AVWAP + k * SD (k is a band multiplier)
Long: bars accumulated since the anchor >= warmup count AND (low <= LowerBand OR (previous close <= previous AVWAP AND close > AVWAP))
Short: bars accumulated since the anchor >= warmup count AND (high >= UpperBand OR (previous close >= previous AVWAP AND close < AVWAP))