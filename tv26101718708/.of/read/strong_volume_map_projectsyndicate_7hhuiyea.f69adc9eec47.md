Calculation: Volume-weighted fair value = rolling volume-weighted mean of HLC3
Calculation: Fair-value dispersion = square root of rolling volume-weighted mean of HLC3 squared minus the square of volume-weighted fair value
Calculation: Volume z-score = (volume − rolling mean volume) / rolling standard deviation of volume
Calculation: Lower-wick fraction = (min(open, close) − low) / (high − low)
Calculation: Upper-wick fraction = (high − max(open, close)) / (high − low)
Calculation: Close location = (close − low) / (high − low)
Long: bar is confirmed AND fair-value dispersion > 0 AND (fair value − low) / fair-value dispersion ≥ stretch threshold AND volume z-score ≥ volume-climax threshold AND lower-wick fraction ≥ rejection-wick threshold AND close location ≥ 0.4 AND bars since prior long signal > cooldown
Short: bar is confirmed AND fair-value dispersion > 0 AND (high − fair value) / fair-value dispersion ≥ stretch threshold AND volume z-score ≥ volume-climax threshold AND upper-wick fraction ≥ rejection-wick threshold AND close location ≤ 0.6 AND bars since prior short signal > cooldown