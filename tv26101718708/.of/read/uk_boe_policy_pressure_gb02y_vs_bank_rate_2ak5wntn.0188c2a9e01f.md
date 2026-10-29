Calculation: Policy gap = government bond yield minus central-bank policy rate
Calculation: Gap EMA = exponential moving average of the policy gap, with a shorter lookback than the gap Z-score
Calculation: Gap Z-score = (policy gap − rolling mean of policy gap) / rolling standard deviation of policy gap, using the same lookback for mean and standard deviation
Long: policy gap ≥ meaningful-gap threshold OR (policy gap ≥ signal-gap threshold AND gap Z-score ≥ Z-score threshold AND policy gap > gap EMA for at least the required number of consecutive chart bars)
Short: policy gap ≤ −meaningful-gap threshold OR (policy gap ≤ −signal-gap threshold AND gap Z-score ≤ −Z-score threshold AND policy gap < gap EMA for at least the required number of consecutive chart bars)