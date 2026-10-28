Calculation: ATR-normalized EMA slope = tanh((EMA(close, long-term length) − its value short-term lookback bars ago) / (ATR × short-term lookback))
Calculation: RSI deviation = (RSI − 50) / 50
Calculation: ATR-normalized return = tanh((close − previous close) / ATR)
Calculation: Signed volume z-score = tanh(((volume − previous volume) / volume standard deviation) × sign(close − previous close) / 2)
Calculation: Signed range expansion = tanh(((high − low) / average(high − low) − 1) × sign(close − previous close))
Calculation: Close-in-range position = 2 × ((close − lowest low) / (highest high − lowest low)) − 1
Calculation: Evidence masses for each strength s = long mass max(s, 0) × |s|; short mass max(−s, 0) × |s|; hold mass 1 − |s|
Calculation: Fused masses = combine the six evidence mass triplets in order using Dempster’s rule: conflict K = aL×bS + aS×bL; combined long = (aL×bL + aL×bH + aH×bL)/(1−K); combined short = (aS×bS + aS×bH + aH×bS)/(1−K); combined hold = aH×bH/(1−K); normalize the three results to sum to 1
Long: fused long mass > signal threshold AND session filter passes AND position is not long AND cooldown has elapsed AND bar is confirmed OR fused long mass crosses above signal threshold OR (fused long mass − fused short mass) crosses above 0
Short: fused short mass > signal threshold AND session filter passes AND position is not short AND cooldown has elapsed AND bar is confirmed OR fused short mass crosses above signal threshold OR (fused long mass − fused short mass) crosses below 0