Calculation: Trend state = on each bar, compare the stochastic main line with a lower and an upper threshold, using equal stochastic lookback and slowing periods. If the absolute change in the Jurik moving average of close over a lookback exceeds ATR divided by a positive multiplier, set the state bearish when stochastic is below the lower threshold or bullish when it is above the upper threshold; otherwise retain the previous state. Initialize the state as neutral.
Calculation: RSI breadth lines = calculate RSI on the selected price; smooth it with the same method and progressively longer periods separated by a fixed step. Count the smoothed RSI series that are strictly greater than their previous-bar values and separately count those that are less than or equal to their previous-bar values. Smooth each count with the same second smoothing method and period to obtain the bullish and bearish breadth lines.
Calculation: Strategy inputs = calculate trend state and RSI breadth lines on the same selected timeframe, which may be higher or lower than the chart timeframe; use either its last completed bar or its still-forming bar according to the selected signal-bar setting. The latest trend signal is the most recent non-neutral change of trend state on or before that bar.
Long: Trend state changes from bearish to bullish.
Short: Trend state changes from bullish to bearish.
Long: Bullish RSI breadth line > bearish RSI breadth line.
Short: Bearish RSI breadth line > bullish RSI breadth line.
Long: Latest trend signal is bullish AND bullish RSI breadth line crosses above bearish RSI breadth line.
Long: Trend state changes from bearish to bullish AND bullish RSI breadth line > bearish RSI breadth line.
Short: Latest trend signal is bearish AND bearish RSI breadth line crosses above bullish RSI breadth line.
Short: Trend state changes from bullish to bearish AND bearish RSI breadth line > bullish RSI breadth line.
Exit: long, latest trend signal is bearish AND bearish RSI breadth line > bullish RSI breadth line.
Exit: short, latest trend signal is bullish AND bullish RSI breadth line > bearish RSI breadth line.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.