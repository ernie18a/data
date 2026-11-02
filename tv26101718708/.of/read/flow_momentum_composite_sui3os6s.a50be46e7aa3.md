Calculation: Momentum = a selected OHLC-derived source minus its value a lookback ago, divided by ATR of the same lookback, or zero if ATR is not positive; multiply by a sensitivity, add the midpoint of a 0–100 scale, clamp to that scale, and smooth with a selected EMA, SMA, or RMA. Calculate core momentum and balance momentum with independently selectable lookbacks and smoothing lengths, using the same source, sensitivity, and smoothing method; balance smoothing is typically longer.
Calculation: Flow pressure = smooth the following with the same moving-average method as momentum: midpoint plus half the scale width times the rolling sum of signed pressure divided by the rolling sum of its weights; use the midpoint if the denominator is zero. On each bar, use volume as the weight and signed volume as pressure, positive when close > open, negative when close < open, and zero otherwise, if volume is available, its rolling standard deviation is positive, and candle mode is not forced. Otherwise use weight one and pressure (close - open) / (high - low), or zero when the range is zero. The volume-detection and pressure-sum lookbacks are independent.
Calculation: Structure direction = initially bullish; change to bearish when close < EMA(close) - ATR × band multiplier, and change to bullish when close > EMA(close) + ATR × band multiplier; otherwise retain the previous direction. EMA and ATR use the same lookback.
Calculation: Tension = core momentum - balance momentum. Bullish deepening means tension > 0 AND previous tension > 0 AND tension > previous tension. Bearish deepening means tension <= 0 AND previous tension <= 0 AND tension < previous tension.
Calculation: KNN vote = compare the current feature vector (core momentum / scale maximum, flow pressure / scale maximum, bullish structure as 1 or bearish structure as 0) with stored prior-bar feature vectors using Euclidean distance. Label each stored vector 1 if the following close > its close, otherwise 0; retain the most recent memory-length observations. Select the configured number of nearest observations, breaking distance ties by earliest stored observation, and calculate the percentage of positive labels weighted by 1 / (distance + a positive distance offset). Use the scale midpoint until enough observations exist or when the selected neighbors' average distance exceeds a confidence limit.
Calculation: Composite score = on a bullish candle, sum the respective configurable weights for core momentum > midpoint AND rising, flow pressure > midpoint, bullish structure, KNN vote > upper KNN threshold, and bullish deepening tension; on a bearish candle, sum the weights for core momentum < midpoint AND falling, flow pressure < midpoint, bearish structure, KNN vote < lower KNN threshold, and bearish deepening tension. Divide by the sum of all five weights and express as a percentage; use zero if their sum is zero. A doji has zero score. The lower KNN threshold is below the midpoint and the upper threshold is above it.
Calculation: Momentum wave signal availability = maintain separate long and short used flags, initially false. Reset both when core momentum crosses strictly above the midpoint from at or below it, or strictly below the midpoint from at or above it. When the optional one-signal-per-wave restriction is enabled, set the corresponding flag after a composite score signal and require that flag to be false for the next same-direction composite score signal.
Calculation: Momentum pivot = a local high or low of core momentum confirmed after the same configurable number of bars on each side; compare consecutive pivots of the same type, using the price high or low at each momentum pivot bar. Evaluate divergence on the confirmation bar.
Long: close > open AND composite score >= signal threshold AND long wave signal availability = true.
Short: close < open AND composite score >= signal threshold AND short wave signal availability = true.
Long: core momentum > oversold threshold AND previous core momentum <= oversold threshold.
Short: core momentum < overbought threshold AND previous core momentum >= overbought threshold.
Long: a momentum low pivot is confirmed AND its momentum > the previous momentum low pivot AND its price low < the price low at the previous momentum low pivot.
Short: a momentum high pivot is confirmed AND its momentum < the previous momentum high pivot AND its price high > the price high at the previous momentum high pivot.
Long: core momentum >= balance momentum.
Short: core momentum < balance momentum.
Long: core momentum >= midpoint.
Short: core momentum < midpoint.
Long: flow pressure >= midpoint.
Short: flow pressure < midpoint.
Long: structure direction = bullish.
Short: structure direction = bearish.
Long: KNN vote >= upper KNN threshold.
Short: KNN vote <= lower KNN threshold.
Long: tension > 0.
Short: tension <= 0.
Long: bullish deepening tension = true.
Short: bearish deepening tension = true.
Long: close > open.
Short: close < open.