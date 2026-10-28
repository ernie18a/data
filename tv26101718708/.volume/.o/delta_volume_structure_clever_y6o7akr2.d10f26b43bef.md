Calculation: Estimated delta = volume × (2 × close − high − low) / (high − low); when high = low, use volume if close ≥ open, otherwise −volume
Calculation: Cumulative delta = running sum of estimated delta, resetting at each new day
Long: confirmed price pivot low is lower than the previous price pivot low AND the simultaneous cumulative-delta pivot low is higher than the previous cumulative-delta pivot low
Short: confirmed price pivot high is higher than the previous price pivot high AND the simultaneous cumulative-delta pivot high is lower than the previous cumulative-delta pivot high
Long: volume ≥ its moving average × high-volume multiplier AND |estimated delta / volume × 100| < absorption threshold AND close > open
Short: volume ≥ its moving average × high-volume multiplier AND |estimated delta / volume × 100| < absorption threshold AND close < open
Long: volume ≥ its moving average × climax-volume multiplier AND |estimated delta / volume × 100| > 60 AND estimated delta > 0
Short: volume ≥ its moving average × climax-volume multiplier AND |estimated delta / volume × 100| > 60 AND estimated delta < 0
Long: volume ≥ its moving average × high-volume multiplier AND estimated delta > 0
Short: volume ≥ its moving average × high-volume multiplier AND estimated delta < 0