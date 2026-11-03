Long: open < EMA(high) AND close > EMA(high) AND (VWAP(close) <= close OR (VWAP(close) >= open AND VWAP(close) <= open + abs(close - open) * configured body fraction)
Short: open > EMA(low) AND close < EMA(low) AND (VWAP(close) >= close OR (VWAP(close) <= open AND VWAP(close) >= open - abs(close - open) * configured body fraction)
Calculation: Long initial stop = low of the bar that produced the Long condition
Calculation: Short initial stop = high of the bar that produced the Short condition
Calculation: Bars in trade = current bar index − entry bar index
Exit: Long, low <= long initial stop OR low <= active long trailing stop OR bars in trade >= configured holding duration
Exit: Short, high >= short initial stop OR high >= active short trailing stop OR bars in trade >= configured holding duration