Calculation: Range position = (close - lowest low over the range lookback) / max(highest high over the range lookback - lowest low over the range lookback, ATR multiplied by a small positive floor factor); extrema include the current bar.
Calculation: Relative volatility = standard deviation of close / SMA of close, using the same lookback for both.
Calculation: Consolidation = relative volatility < its SMA over the range lookback multiplied by a volatility factor.
Calculation: High volume = volume > SMA of volume over the range lookback multiplied by a high-volume factor.
Calculation: Low volume = volume < SMA of volume over the range lookback multiplied by a low-volume factor.
Calculation: Spring = close > open AND low < the lowest low over a shorter swing lookback ending on the previous bar AND close > that lowest low AND volume > SMA of volume over a still shorter lookback.
Calculation: Upthrust = close < open AND high > the highest high over the swing lookback ending on the previous bar AND close < that highest high AND volume > SMA of volume over the still shorter lookback.
Calculation: Strength = close > open AND close > the highest close over a short breakout lookback ending on the previous bar AND volume > SMA of volume over that breakout lookback AND MACD histogram > 0.
Calculation: Weakness = close < open AND close < the lowest close over the short breakout lookback ending on the previous bar AND volume > SMA of volume over that breakout lookback AND MACD histogram < 0. The breakout lookback is shorter than the swing lookback and longer than the still shorter volume lookback.
Calculation: Support retest = close > open AND high volume is false AND shortest close EMA > intermediate close EMA AND range position > a support threshold.
Calculation: Supply retest = close < open AND high volume is false AND shortest close EMA <= intermediate close EMA AND range position < a supply threshold; the supply threshold is higher than the support threshold.
Calculation: Accumulation score = the sum of a double weight when range position < a lower threshold, a single weight when intermediate close EMA <= longest close EMA, a double weight when consolidation is true, a single weight when low volume AND consolidation are true, a single weight when RSI < its midpoint, and a single weight when MACD histogram > its value a fixed number of bars earlier.
Calculation: Distribution score = the sum of a double weight when range position > an upper threshold, a single weight when intermediate close EMA > longest close EMA, a double weight when consolidation is true, a single weight when low volume AND consolidation are true, a single weight when RSI > its midpoint, and a single weight when MACD histogram < its value the same number of bars earlier. The upper range-position threshold is higher than the lower threshold.
Calculation: Accumulation state = accumulation score >= a score threshold AND accumulation score > distribution score on each of a fixed number of consecutive bars. Distribution state = distribution score >= the same score threshold AND distribution score > accumulation score on each of the same number of consecutive bars.
Calculation: Accumulation phase = 0 whenever accumulation state is false; otherwise initialize to A if 0, then sequentially advance A to B when consolidation is true, B to C when spring is true, C to D when strength is true, and D to E when shortest close EMA > intermediate close EMA AND consolidation is false. Apply all applicable advances in order on the same bar. Distribution phase = 0 whenever distribution state is false; otherwise initialize to A if 0, then sequentially advance A to B when consolidation is true, B to C when upthrust is true, C to D when weakness is true, and D to E when shortest close EMA <= intermediate close EMA AND consolidation is false. Apply all applicable advances in order on the same bar.
Calculation: Raw buy state = distribution state is false AND (accumulation phase is C or D OR spring is true OR accumulation state AND support retest are true). Raw sell state = accumulation state is false AND (distribution phase is C or D OR upthrust is true OR distribution state AND supply retest are true).
Long: close < open AND high volume is true AND (high - close) / max(high - low, a small positive price floor) > a climax bar-position threshold AND close <= lowest low over the range lookback multiplied by a factor slightly above one.
Short: close > open AND high volume is true AND (close - low) / max(high - low, the same price floor) > the climax bar-position threshold AND close >= highest high over the range lookback multiplied by a factor slightly below one.
Long: spring is true.
Short: upthrust is true.
Long: strength is true.
Short: weakness is true.
Long: accumulation state is true AND support retest is true.
Short: distribution state is true AND supply retest is true.
Long: raw buy state is true AND raw buy state was false on the previous bar.
Short: raw sell state is true AND raw sell state was false on the previous bar.
Long: accumulation phase is not 0 AND accumulation phase differs from its previous-bar value.
Short: distribution phase is not 0 AND distribution phase differs from its previous-bar value.