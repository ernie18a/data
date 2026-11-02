Calculation: Session price correlation = Pearson correlation between bar order and close over the current session through the current bar; retain the preceding session's last correlation until the current session has at least two bars, and treat an undefined correlation as zero.
Calculation: Session volume delta = sum of volume for session bars with close >= open minus sum of volume for session bars with close < open; retain the last session's delta outside the session.
Calculation: Overall volume delta = sum of the session volume deltas for all currently active sessions, counting overlapping sessions separately.
Long: Session price correlation > 0
Short: Session price correlation <= 0
Long: Session volume delta > 0
Short: Session volume delta < 0
Long: Overall volume delta > 0
Short: Overall volume delta < 0