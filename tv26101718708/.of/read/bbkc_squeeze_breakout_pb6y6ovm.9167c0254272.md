Calculation: Bars since chart-timeframe BB squeeze ended = 0 while Bollinger Band upper < Keltner Channel upper AND Bollinger Band lower > Keltner Channel lower; otherwise increment by one each bar
Calculation: Initial stop = breakout-bar low for a long or breakout-bar high for a short when candle-based stops are selected; otherwise entry price offset by the selected stop percentage, tightened to the enabled maximum-loss-per-position distance
Calculation: Initial risk = greater of the distance between entry price and initial stop and one minimum tick
Calculation: Take-profit price = entry price plus initial risk times the selected reward-to-risk multiple for a long, or minus it for a short
Calculation: Active stop = initial stop until price reaches entry price plus initial risk times the breakeven trigger for a long, or entry price minus that amount for a short; then active stop = entry price
Long: Completed chart-timeframe bar AND flat position AND bars since chart-timeframe BB squeeze ended <= selected grace period AND close > upper Keltner Channel AND (one-trade-per-breakout filter disabled OR no entry since the most recent chart-timeframe squeeze began)
Short: Completed chart-timeframe bar AND flat position AND bars since chart-timeframe BB squeeze ended <= selected grace period AND close < lower Keltner Channel AND (one-trade-per-breakout filter disabled OR no entry since the most recent chart-timeframe squeeze began)
Exit: Long, low <= active stop OR high >= take-profit price
Exit: Short, high >= active stop OR low <= take-profit price