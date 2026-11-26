Calculation: Signed volume delta = on each confirmed chart bar, sum over its last-completed T1 bars the selected volume source multiplied by the sign of the change in selected price source; if lower-timeframe delta is disabled or unavailable, use selected volume source × ((close − low) − (high − close)) / (high − low), or zero when high = low
Calculation: Synthetic bar closes on a confirmed chart bar when the absolute cumulative signed volume delta since the prior synthetic close reaches the positive threshold; threshold is a positive fixed threshold when set, otherwise the greater of standard deviation of signed volume delta over the significance lookback × participation multiplier and the minimum threshold floor
Calculation: Regime = after the high-volatility override, uptrend or downtrend when EfficiencyRatio(synthetic close, regime lookback) >= trend cutoff, according to whether the net synthetic-close change is positive or negative; otherwise range, with transition while history is insufficient
Calculation: Cumulative-delta slope = cumulative sum of synthetic-bar signed volume delta minus that sum at the CVD slope lookback
Calculation: Structural trail = midpoint of the nearest active imbalance level on the support side in an uptrend or resistance side in a downtrend; retain its strength
Calculation: Normalized external bias = clamp(external bias score / external score full scale, −1, 1)
Calculation: Volatility-index bias = −clamp(ROC(volatility-index close, volatility trend lookback) × volatility sensitivity, −1, 1), using the last completed chart-timeframe bar
Calculation: Confidence = logistic of the sum of the trail-strength contribution (or no-trail penalty), regime contribution, trail direction × sign(Cumulative-delta slope) × order-flow weight, minus the hot-VPIN penalty when VPIN(window) exceeds its hot threshold, plus aligned normalized external bias × external-bias weight when enabled and available, plus aligned volatility-index bias × volatility weight when enabled and available
Calculation: Long stop = the greatest structural-trail value since long entry; short stop = the least structural-trail value since short entry
Long: uptrend regime
Short: downtrend regime
Long: uptrend regime AND confidence >= minimum confidence
Short: downtrend regime AND confidence >= minimum confidence
Long: position is flat AND confirmed chart bar closes a synthetic bar AND regime is uptrend AND structural trail exists AND confidence >= minimum entry confidence AND Cumulative-delta slope > 0 AND (external bias is disabled OR Normalized external bias > negative alignment threshold)
Short: position is flat AND confirmed chart bar closes a synthetic bar AND regime is downtrend AND structural trail exists AND confidence >= minimum entry confidence AND Cumulative-delta slope < 0 AND (external bias is disabled OR Normalized external bias < positive alignment threshold)
Exit: long, on a confirmed chart bar, close < Long stop OR regime is not uptrend
Exit: short, on a confirmed chart bar, close > Short stop OR regime is not downtrend