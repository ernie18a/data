Calculation: Aligned MA score = +1 when close and moving averages of close with progressively longer lookbacks are fully ordered upward; -1 when fully ordered downward; otherwise, if partial alignment is enabled, count the seven upward-order comparisons: score +0.5 if more than five hold, -0.5 if fewer than two hold, +0.25 if more than three hold, otherwise -0.25; if partial alignment is disabled, score 0
Calculation: Aligned MA index = rolling sum of the aligned MA score
Calculation: High-low index = +1 if the bar's high equals the rolling highest high, otherwise -1 if its low equals the rolling lowest low, otherwise 0
Calculation: Cumulative high-low index = rolling sum of the high-low index
Calculation: Change direction = +1 when the series is greater than its prior-bar value, -1 when less, and otherwise retain the prior nonzero direction (initially 0)
Calculation: Yearly high filter = true if disabled; otherwise use the high of the last completed annual bar (H0), plus H1 and H2 from 365 and 730 chart bars earlier: (H0 or H1 missing or H0 > H1) AND (H0 or H2 missing or H0 > H2), OR H0 missing, OR (H1 missing AND close > H0), OR (H2 missing AND close > max(H0,H1)), OR close > max(H0,min(H1,H2))
Calculation: Yearly low filter = true if disabled; otherwise use the low of the last completed annual bar (L0), plus L1 and L2 from 365 and 730 chart bars earlier: (L0 or L1 missing or L0 < L1) AND (L0 or L2 missing or L0 < L2), OR L0 missing, OR (L1 missing AND close < L0), OR (L2 missing AND close < min(L0,L1)), OR close < min(L0,max(L1,L2))
Long: Supertrend direction is bullish AND change direction of the aligned MA index is +1 AND change direction of the cumulative high-low index is +1 AND yearly high filter
Short: Supertrend direction is bearish AND change direction of the aligned MA index is -1 AND change direction of the cumulative high-low index is -1 AND yearly low filter
Exit: Long, Supertrend direction is bearish
Exit: Short, Supertrend direction is bullish