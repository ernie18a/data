Calculation: SessionHigh(W) = highest high over the bars of the last completed occurrence of session window W
Calculation: SessionLow(W) = lowest low over the bars of the last completed occurrence of session window W
Calculation: NoPriorBreakout(W) = no earlier bar since the most recent start of session window W is outside W and (crosses above SessionHigh(W) or crosses below SessionLow(W))
Long: bar is outside session window W1 AND NoPriorBreakout(W1) AND close crosses above SessionHigh(W1)
Short: bar is outside session window W1 AND NoPriorBreakout(W1) AND close crosses below SessionLow(W1)
Long: bar is outside session window W2 AND NoPriorBreakout(W2) AND close crosses above SessionHigh(W2)
Short: bar is outside session window W2 AND NoPriorBreakout(W2) AND close crosses below SessionLow(W2)
Long: bar is outside session window W3 AND NoPriorBreakout(W3) AND close crosses above SessionHigh(W3)
Short: bar is outside session window W3 AND NoPriorBreakout(W3) AND close crosses below SessionLow(W3)