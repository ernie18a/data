Calculation: Pivot-up structure = latest confirmed pivot high > preceding confirmed pivot high AND latest confirmed pivot low > preceding confirmed pivot low, using equal left and right pivot lookbacks
Calculation: Pivot-down structure = latest confirmed pivot high < preceding confirmed pivot high AND latest confirmed pivot low < preceding confirmed pivot low, using equal left and right pivot lookbacks
Calculation: VWAP slope = VWAP(hlc3) minus VWAP(hlc3) at the primary lag, or at the fallback lag if unavailable
Calculation: Trend strength ratio = abs(LinReg(close, trend lookback, 0) - LinReg(close, trend lookback, trend lookback minus one)) / ATR(ATR lookback), or zero if ATR is not positive
Calculation: Average body fraction = average of abs(close - open) / (high - low) over the momentum lookback, using zero when high equals low
Calculation: Momentum level(side) = 2 if the count of bars in the momentum lookback with close > open for long or close < open for short is at least round(momentum fraction * momentum lookback), average body fraction >= strong body threshold, and volume / SMA(volume, volume lookback) >= strong volume threshold; otherwise 1 if the count meets that requirement, average body fraction >= moderate body threshold, and volume / SMA(volume, volume lookback) >= moderate volume threshold; otherwise 0, with volume ratio equal to 1 if the SMA is not positive
Calculation: Conviction(side) = clamp(zero, maximum score, side trend level + Momentum level(side) + clamp(negative one, positive one, VWAP vote(side) + EMA vote(side))); side trend level is 2 when side pivot structure holds and trend strength ratio >= strong trend threshold, 1 when it holds and trend strength ratio >= moderate trend threshold and < strong trend threshold, otherwise zero; side trend level is zero without side pivot structure; VWAP vote is +1 when close is above VWAP and VWAP slope > 0 for long, or close is below VWAP and VWAP slope < 0 for short; it is -1 when close is below VWAP or VWAP slope < 0 for long, or close is above VWAP or VWAP slope > 0 for short; otherwise zero; EMA vote is +1 when the EMA stack matches the side, -1 when it opposes the side, otherwise zero; EMA stack uses separate shorter, middle, and longer lookbacks
Long: Pivot-up structure
Short: Pivot-down structure
Long: Momentum level(long) > 0
Short: Momentum level(long) = 0 AND Momentum level(short) > 0
Long: EMA(close, shorter lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longer lookback)
Long: close > VWAP(hlc3) OR VWAP slope > 0
Short: close < VWAP(hlc3)
Long: Conviction(long) > Conviction(short) AND Conviction(long) > zero
Short: Conviction(short) > Conviction(long) AND Conviction(short) > zero