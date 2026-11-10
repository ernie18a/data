Calculation: Agent votes = trend vote is +1 when the shorter EMA of close is above the longer EMA, -1 when below, otherwise 0; momentum vote is +1 when RSI is above the upper threshold, -1 when below the lower threshold, otherwise 0; volume vote is the sign of close minus open when the volume z-score is at least its threshold, otherwise 0. Volume z-score is (volume minus its SMA) divided by its standard deviation over the same lookback, or 0 when the standard deviation is 0.
Calculation: Agent weights = initialize each agent's weight to an initial weight. On each completed bar, record the current close and direction when the trend or momentum vote changes to a nonzero vote, and on every bar with a nonzero volume vote. Age all pending records, including newly recorded ones, by one bar. When a record reaches the outcome horizon, its outcome is 1 if its recorded direction multiplied by (current close minus recorded close) is at least a required multiple of current ATR, otherwise 0. Update its agent's weight to the old weight plus the learning rate multiplied by (outcome minus old weight), clamped between lower and upper weight bounds. Process records reaching the horizon in reverse insertion order and remove them after updating. If learned weights are disabled, use equal unit weights instead.
Calculation: Weighted vote sum = sum of each agent vote multiplied by its current weight, after processing matured records.
Calculation: Consensus = +1 if the count of +1 agent votes is at least the minimum vote count AND the weighted vote sum is above 0; otherwise -1 if the count of -1 agent votes is at least the minimum vote count AND the weighted vote sum is below 0; otherwise 0.
Long: shorter EMA of close > longer EMA of close
Short: shorter EMA of close < longer EMA of close
Long: RSI > upper threshold
Short: RSI < lower threshold
Long: volume z-score >= threshold AND close > open
Short: volume z-score >= threshold AND close < open
Long: weighted vote sum > 0
Short: weighted vote sum < 0
Long: consensus = +1
Short: consensus = -1
Long: consensus = +1 AND previous bar's consensus != +1
Short: consensus = -1 AND previous bar's consensus != -1