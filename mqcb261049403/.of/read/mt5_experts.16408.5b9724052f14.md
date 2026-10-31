Calculation: Rounded trend line = Jurik moving average of the SATL digital filter of a selected OHLC-derived price, rounded to a selectable price increment.
Calculation: Trend state = +1 when the rounded trend line is above its previous-bar value, -1 when below, and otherwise the previous trend state. Calculate it on the chart timeframe for indicator markings; for trading decisions, calculate it on a selectable higher or lower timeframe using a selectable completed bar or the bar still forming.
Long: Chart-timeframe trend state = +1.
Short: Chart-timeframe trend state = -1.
Long: Direct mode AND trading trend state = +1 AND previous trading trend state = -1 OR inverse mode AND trading trend state = -1 AND previous trading trend state = +1.
Short: Direct mode AND trading trend state = -1 AND previous trading trend state = +1 OR inverse mode AND trading trend state = +1 AND previous trading trend state = -1.
Exit: long, direct mode AND trading trend state = -1 OR inverse mode AND trading trend state = +1 OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, direct mode AND trading trend state = +1 OR inverse mode AND trading trend state = -1 OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.