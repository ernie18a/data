Calculation: Session volume delta(session) = cumulative volume on chart bars since the session began with close >= open minus cumulative volume on chart bars since the session began with close < open
Calculation: Overall active-session volume delta = sum of each session's volume delta when the current chart bar is within that session, and zero otherwise
Long: Pearson correlation coefficient(close, sequential chart-bar index since session A began) > 0
Short: Pearson correlation coefficient(close, sequential chart-bar index since session A began) <= 0
Long: Pearson correlation coefficient(close, sequential chart-bar index since session B began) > 0
Short: Pearson correlation coefficient(close, sequential chart-bar index since session B began) <= 0
Long: Pearson correlation coefficient(close, sequential chart-bar index since session C began) > 0
Short: Pearson correlation coefficient(close, sequential chart-bar index since session C began) <= 0
Long: Pearson correlation coefficient(close, sequential chart-bar index since session D began) > 0
Short: Pearson correlation coefficient(close, sequential chart-bar index since session D began) <= 0
Long: Session volume delta(session A) > 0
Short: Session volume delta(session A) < 0
Long: Session volume delta(session B) > 0
Short: Session volume delta(session B) < 0
Long: Session volume delta(session C) > 0
Short: Session volume delta(session C) < 0
Long: Session volume delta(session D) > 0
Short: Session volume delta(session D) < 0
Long: Overall active-session volume delta > 0
Short: Overall active-session volume delta < 0