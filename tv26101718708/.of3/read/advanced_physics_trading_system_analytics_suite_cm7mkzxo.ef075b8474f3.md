Calculation: Capped relative volume = if SMA(volume, lookback) is nonzero, min(volume / SMA(volume, lookback), relative-volume cap); otherwise 1
Calculation: Normalized velocity = if ATR(ATR lookback) is nonzero, (close - close[1]) / ATR(ATR lookback); otherwise 0
Calculation: Acceleration = normalized velocity - normalized velocity[1]
Calculation: Volume work = ROC(close, 1) * capped relative volume
Calculation: Kinetic energy = energy coefficient * capped relative volume * normalized velocity^2
Calculation: Potential energy = energy coefficient * spring constant * ((close - SMA(close, lookback)) / (ATR(ATR lookback) if nonzero, otherwise 1)^2)
Calculation: Force = capped relative volume * acceleration
Calculation: Normalized entropy = Shannon entropy of the frequencies of volume work over lookback bars, divided by log2(5), using five bins split at four ordered entropy-bin thresholds
Calculation: Orderly market = normalized entropy <= entropy threshold
Calculation: Bullish dimension count = count of normalized velocity > 0, acceleration > 0, force > force-agreement threshold, orderly market, and volume work > 0
Calculation: Bearish dimension count = count of normalized velocity < 0, acceleration < 0, force < -force-agreement threshold, orderly market, and volume work < 0
Calculation: Net agreement = bullish dimension count - bearish dimension count
Calculation: Bullish exhaustion = kinetic energy > exhaustion multiplier * kinetic-energy threshold AND acceleration < 0 AND normalized velocity > 0
Calculation: Bearish exhaustion = kinetic energy > exhaustion multiplier * kinetic-energy threshold AND acceleration > 0 AND normalized velocity < 0
Calculation: Physics regime starts neutral; it becomes bullish when net agreement >= agreement threshold and the prior regime is not bullish, and bearish when net agreement <= -agreement threshold and the prior regime is not bearish; otherwise it retains its prior regime
Calculation: Physics flip history = chart-bar close, bar index, and direction at each transition into net agreement >= agreement threshold or <= -agreement threshold, retaining the latest twice the flip-history lookback transitions
Calculation: Average flip height (%) = mean of abs(next flip price - previous flip price) / previous flip price * 100 across consecutive stored flips, or 0 if there are no pairs
Calculation: Time symmetry = mean interval to bullish destination flips / mean interval to bearish destination flips; use 0 unless both means exist and the bearish mean is positive
Calculation: Compression and expansion streaks update on each chart bar when at least two flips exist: compare the latest flip height percentage divided by average flip height; increment the compression streak and reset expansion when below the compression-ratio threshold, increment expansion and reset compression when above the expansion-ratio threshold, otherwise reset both; retain both when fewer than two flips exist
Calculation: Rolling flip high and low = maximum and minimum prices among the latest up to flip-history lookback plus one stored flips; undefined when there are no flips
Calculation: Percent distance to flip high = ((rolling flip high - close) / close) * 100 when the high exists and close > 0, otherwise 0
Calculation: Percent distance to flip low = ((close - rolling flip low) / close) * 100 when the low exists and close > 0, otherwise 0
Calculation: Composite score = (net agreement / 5) * agreement weight + max(time symmetry - 1, 0) * symmetry weight + (ln(average flip height / geometry-score baseline) if average flip height > 0, otherwise 0) * geometry weight + (1 - normalized entropy) * entropy weight
Calculation: Rank score = composite score + net agreement / rank-agreement divisor + (time symmetry - 1) * rank-symmetry weight
Long: normalized velocity > 0
Short: normalized velocity <= 0
Long: acceleration > 0
Short: acceleration <= 0
Long: volume work > 0
Short: volume work <= 0
Long: force > 0
Short: force <= 0
Long: force > force-agreement threshold
Short: force < -force-agreement threshold
Long: acceleration > 0 AND normalized velocity > velocity threshold AND kinetic energy > kinetic-energy threshold AND volume work > 0 AND orderly market
Short: acceleration < 0 AND normalized velocity < -velocity threshold AND kinetic energy > kinetic-energy threshold AND volume work < 0 AND orderly market
Long: bullish dimension count == 5
Short: bearish dimension count == 5
Long: force > 0 AND normalized velocity > 0 AND orderly market AND kinetic energy < kinetic-energy threshold AND potential energy > potential-energy threshold AND net agreement > 0 AND force > spring-release force threshold AND kinetic energy[1] < kinetic-energy threshold AND potential energy[1] > potential-energy threshold AND orderly market[1]
Short: force > 0 AND normalized velocity > 0 AND orderly market AND kinetic energy < kinetic-energy threshold AND potential energy > potential-energy threshold AND net agreement < 0 AND force > spring-release force threshold AND kinetic energy[1] < kinetic-energy threshold AND potential energy[1] > potential-energy threshold AND orderly market[1]
Exit: long, bullish exhaustion
Exit: short, bearish exhaustion
Long: physics regime is bullish
Short: physics regime is bearish
Long: net agreement > 0
Short: net agreement < 0
Long: net agreement >= agreement threshold
Short: net agreement <= -agreement threshold
Long: time symmetry > bullish symmetry threshold
Short: time symmetry < bearish symmetry threshold
Long: rank score > rank-color threshold
Short: rank score < -rank-color threshold
Long: rank score > rank-score threshold
Short: rank score < -rank-score threshold
Long: bullish dimension count == 5 AND rank score > rank-score threshold
Long: composite score > composite-positive color threshold
Short: composite score < -composite-negative color threshold
Long: compression streak >= minimum compression streak AND abs(percent distance to flip high) <= near-extreme threshold AND net agreement > 0
Short: compression streak >= minimum compression streak AND abs(percent distance to flip low) <= near-extreme threshold AND net agreement < 0
Long: expansion streak >= minimum expansion streak AND rolling flip high exists AND close > rolling flip high AND net agreement >= agreement threshold
Short: expansion streak >= minimum expansion streak AND rolling flip low exists AND close < rolling flip low AND net agreement <= -agreement threshold
Long: expansion streak >= minimum expansion streak AND time symmetry > bullish symmetry threshold AND net agreement >= agreement threshold
Short: expansion streak >= minimum expansion streak AND time symmetry < bearish symmetry threshold AND net agreement <= -agreement threshold
Long: net agreement >= agreement threshold AND time symmetry > bullish symmetry threshold AND average flip height > geometry swing threshold AND orderly market
Short: net agreement <= -agreement threshold AND time symmetry < bearish symmetry threshold AND average flip height > geometry swing threshold AND orderly market