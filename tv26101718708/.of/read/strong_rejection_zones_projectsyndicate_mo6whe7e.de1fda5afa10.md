Long: A pivot low is confirmed using equal left and right lookbacks.
Long: High > low AND (min(open, close) - low) / (high - low) >= wick dominance threshold.
Long: Volume SMA > 0 AND volume >= volume SMA × volume spike multiplier AND close >= open.
Short: A pivot high is confirmed using equal left and right lookbacks.
Short: High > low AND (high - max(open, close)) / (high - low) >= wick dominance threshold.
Short: Volume SMA > 0 AND volume >= volume SMA × volume spike multiplier AND close < open.