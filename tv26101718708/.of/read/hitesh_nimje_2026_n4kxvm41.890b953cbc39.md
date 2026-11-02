Calculation: Session price correlation = Pearson correlation between bar order and close for the bars accumulated in a session; reset the accumulation at session start, update the correlation from the second session bar, and otherwise retain its previous value, including on the first session bar and outside the session.
Calculation: Session volume delta = cumulative volume of session bars with close >= open minus cumulative volume of session bars with close < open; reset at session start and retain the last value outside the session.
Calculation: Overall volume delta = sum of session volume deltas for sessions active on the current bar.
Long: Session price correlation > 0.
Short: Session price correlation <= 0 OR session price correlation is undefined.
Long: Session volume delta > 0.
Short: Session volume delta <= 0.
Long: Overall volume delta > 0.
Short: Overall volume delta < 0.