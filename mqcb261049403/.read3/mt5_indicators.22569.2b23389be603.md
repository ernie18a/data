Calculation: adjusted smoothed open = if abs(open - close) <= gap then previous smoothed close else selected_smoother(open, method, phase, lookback); initialize previous smoothed close to the first bar's close
Calculation: trend state = bullish if adjusted smoothed open < selected_smoother(close, method, phase, lookback), bearish if greater, otherwise previous trend state; initialize to neutral
Long: previous trend state was bearish or neutral AND current trend state is bullish
Short: previous trend state was bullish or neutral AND current trend state is bearish