Calculation: Fast LWMA = linearly weighted moving average of typical price over a shorter lookback on a higher timeframe, using the bar still forming
Calculation: Slow LWMA = linearly weighted moving average of typical price over a longer lookback on the same higher timeframe, using the bar still forming
Long: number of open positions < maximum allowed AND abs(current bar open - close 2 bars ago) > minimum price-movement threshold AND Fast LWMA > Slow LWMA AND low 2 bars ago < high 1 bar ago
Short: number of open positions < maximum allowed AND abs(current bar open - close 2 bars ago) > minimum price-movement threshold AND Fast LWMA < Slow LWMA AND low 1 bar ago < high 2 bars ago
Exit: Long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: Short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance