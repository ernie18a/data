Calculation: Phase point = (x, y), where x = (RSI − 50) / 50 and y = (smoothed Stochastic %K − 50) / 50; calculate each on each of the four configured timeframes, ordered from shorter-term to longer-term. For timeframes higher than the chart, use the last completed bar in confirmed mode; the optional developing mode uses the still-forming bar.
Calculation: Weighted centroid = the weighted mean of the four phase points, using weights normalized to sum to 1.
Calculation: Tightness = clamp(1 − weighted root-mean-square Euclidean distance of the four points from their centroid / reference, 0, 1).
Calculation: Rotation agreement = weighted mean of the four signs of negative wrapped per-bar changes in atan2(y, x); clockwise rotation contributes positive agreement and counterclockwise rotation negative agreement.
Calculation: Centroid magnitude = the centroid's distance from the origin, capped at 1.
Calculation: Bull score = cube root of tightness × max(rotation agreement, 0) × centroid magnitude.
Calculation: Bear score = cube root of tightness × max(−rotation agreement, 0) × centroid magnitude.
Long: On a confirmed chart bar, bull score ≥ threshold AND previous bull score < threshold.
Short: On a confirmed chart bar, bear score ≥ threshold AND previous bear score < threshold.