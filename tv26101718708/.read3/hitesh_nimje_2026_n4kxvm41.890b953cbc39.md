Calculation: Session correlation = Pearson correlation between close and ascending bar index across chart bars since each session start
Calculation: Session volume delta = cumulative volume where close >= open minus cumulative volume where close < open across chart bars since each session start
Long: close > EMA(close, lookback)
Short: close < EMA(close, lookback)
Long: Session correlation(session 1) > 0
Long: Session correlation(session 2) > 0
Long: Session correlation(session 3) > 0
Long: Session correlation(session 4) > 0
Short: Session correlation(session 1) <= 0
Short: Session correlation(session 2) <= 0
Short: Session correlation(session 3) <= 0
Short: Session correlation(session 4) <= 0
Long: Session volume delta(session 1) > 0
Long: Session volume delta(session 2) > 0
Long: Session volume delta(session 3) > 0
Long: Session volume delta(session 4) > 0
Short: Session volume delta(session 1) < 0
Short: Session volume delta(session 2) < 0
Short: Session volume delta(session 3) < 0
Short: Session volume delta(session 4) < 0
Long: Sum of Session volume delta for active sessions > 0
Short: Sum of Session volume delta for active sessions < 0