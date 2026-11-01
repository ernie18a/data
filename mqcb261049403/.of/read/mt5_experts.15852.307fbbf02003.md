Calculation: Applied price = selectable open, high, low, close, (high + low)/2, (high + low + close)/3, (high + low + 2 × close)/4, (open + close)/2, (open + high + low + close)/4, or one of: high if close > open, low if close < open, otherwise close; (high + close)/2 if close > open, (low + close)/2 if close < open, otherwise close; (high + low + 2 × close)/2 if close = open, (high + 2 × low + close)/2 if close < open, otherwise (2 × high + low + close)/2.
Calculation: Volume-weighted moving average = sum of applied price × volume over the lookback divided by sum of volume over the same lookback, plus a fixed price offset. For indicator markings use the chart timeframe; for trading decisions use the selected chart, higher, or lower timeframe and the selected completed or still-forming bar.
Calculation: Change = current volume-weighted moving average minus its previous bar value, rounded to the instrument price precision plus two decimal places.
Calculation: Thresholds = population standard deviation of the unrounded changes in the volume-weighted moving average over a separate lookback, multiplied by each of two independently selectable coefficients and rounded to the instrument price precision plus two decimal places.
Long: Change > first threshold AND change <= second threshold OR change > second threshold.
Short: Change < -first threshold AND change >= -second threshold OR change < -second threshold.
Long: Volume-weighted moving average > its previous bar value.
Short: Volume-weighted moving average < its previous bar value.
Long: Volume-weighted moving average > its previous bar value AND its previous bar value < its value two bars ago.
Short: Volume-weighted moving average < its previous bar value AND its previous bar value > its value two bars ago.
Exit: long, change < -first threshold AND change >= -second threshold OR change < -second threshold OR volume-weighted moving average < its previous bar value.
Exit: short, change > first threshold AND change <= second threshold OR change > second threshold OR volume-weighted moving average > its previous bar value.
Exit: long, low <= entry price minus the enabled stop-loss distance OR high >= entry price plus the enabled take-profit distance.
Exit: short, high >= entry price plus the enabled stop-loss distance OR low <= entry price minus the enabled take-profit distance.