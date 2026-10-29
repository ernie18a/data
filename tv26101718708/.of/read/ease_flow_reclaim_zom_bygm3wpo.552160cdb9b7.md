Calculation: Ease of Movement = EMA of ((current and previous bar midpoint change) divided by (volume divided by 100,000 and divided by bar range, with zero volume handled as inverse bar range and bar range floored at minimum tick size)
Calculation: Ease impulse = Ease of Movement minus its value at a shorter lookback
Calculation: Downside stress = square root of the simple moving average of squared percentage differences between close and the highest close over the stress lookback
Calculation: Upside stress = square root of the simple moving average of squared percentage differences between close and the lowest close over the stress lookback
Calculation: Bullish flow = Ease of Movement > 0 AND Ease impulse > 0
Calculation: Bearish flow = Ease of Movement < 0 AND Ease impulse < 0
Calculation: Downside stress easing = downside stress < its prior-bar value AND its prior-bar value > a stress floor
Calculation: Upside stress easing = upside stress < its prior-bar value AND its prior-bar value > a stress floor
Calculation: Fast volume-weighted average = volume-weighted average of close over a shorter lookback than the slow volume-weighted average
Calculation: Slow volume-weighted average = volume-weighted average of close over a longer lookback
Calculation: Reclaim average = Hull moving average of close
Calculation: Bullish trend = fast volume-weighted average > slow volume-weighted average AND reclaim average > its prior-bar value
Calculation: Bearish trend = fast volume-weighted average < slow volume-weighted average AND reclaim average < its prior-bar value
Calculation: Bullish reclaim = close > reclaim average AND prior close <= prior reclaim average
Calculation: Bearish rejection = close < reclaim average AND prior close >= prior reclaim average
Calculation: Bullish component count = number of satisfied conditions among bullish flow, downside stress easing, bullish trend, and bullish reclaim
Calculation: Bearish component count = number of satisfied conditions among bearish flow, upside stress easing, bearish trend, and bearish rejection
Calculation: Cooldown eligible = no prior confirmed long or short signal OR bars since the last confirmed signal > configured cooldown
Long: bullish component count = configured required count minus 1 OR (bullish component count >= configured required count AND cooldown eligible)
Short: bearish component count = configured required count minus 1 OR (bearish component count >= configured required count AND cooldown eligible)