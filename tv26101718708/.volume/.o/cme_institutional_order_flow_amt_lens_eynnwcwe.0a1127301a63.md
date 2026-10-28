Calculation: Geometric delta = volume × (2 × (close − low) / (high − low) − 1); use zero when high = low
Calculation: Relative volume = current volume / trailing average volume; on hourly bars, use the average for the same hour from earlier completed bars when available
Calculation: Delta intensity = absolute delta / trailing average absolute delta
Calculation: Lower wick fraction = (min(open, close) − low) / (high − low)
Calculation: Upper wick fraction = (high − max(open, close)) / (high − low)
Calculation: Body fraction = absolute(close − open) / (high − low)
Long: lower wick fraction ≥ the absorption wick threshold AND close ≥ low + 0.5 × (high − low) AND (relative volume ≥ the absorption volume threshold OR delta intensity ≥ its threshold) AND (delta < 0 OR absolute(delta / volume) ≥ the absorption delta threshold) AND not in the cash-open blackout
Long: relative volume ≥ the initiative volume threshold AND body fraction ≥ the initiative body threshold AND close > open AND (delta > 0 OR delta / volume ≥ the initiative delta threshold)
Short: upper wick fraction ≥ the absorption wick threshold AND close ≤ high − 0.5 × (high − low) AND (relative volume ≥ the absorption volume threshold OR delta intensity ≥ its threshold) AND (delta > 0 OR absolute(delta / volume) ≥ the absorption delta threshold) AND not in the cash-open blackout
Short: relative volume ≥ the initiative volume threshold AND body fraction ≥ the initiative body threshold AND close < open AND (delta < 0 OR delta / volume ≤ the initiative negative-delta threshold)
