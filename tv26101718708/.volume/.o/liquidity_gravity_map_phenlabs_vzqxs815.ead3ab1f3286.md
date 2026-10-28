Calculation: Swing length = rounded max(2, zone sensitivity + 1) bars; a confirmed swing low/high is a low/high that is the lowest/highest across that many bars on both sides.
Calculation: Sweep window = max(5, rounded 25% of the lookback period) bars.
Long: A confirmed swing low OR low < lowest low of the prior sweep window AND close > low + 0.35 × (high − low) AND (min(open, close) − low) / (high − low) ≥ 0.45
Short: A confirmed swing high OR high > highest high of the prior sweep window AND close < high − 0.35 × (high − low) AND (high − max(open, close)) / (high − low) ≥ 0.45