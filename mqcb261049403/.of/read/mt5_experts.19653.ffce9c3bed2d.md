Calculation: Filtered line = round the Jurik moving average of the fast adaptive trend line (FATL) of a selected OHLC-derived price to a configurable price increment; calculate on the chart timeframe or a configurable higher or lower timeframe, using the last completed bar or the still-forming bar as configured.
Calculation: Trend state = sign of the change in the filtered line from its previous bar; when the change is zero, retain the previous trend state.
Long: Trend state = positive AND previous trend state is not positive.
Short: Trend state = negative AND previous trend state is not negative.
Exit: long, trend state = negative OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, trend state = positive OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.