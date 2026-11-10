Calculation: Confirmed swing high or low = a pivot high or low with equal configurable numbers of bars on each side; it becomes available on the confirmation bar. Use the most recently confirmed pivot of each type, including pivots confirmed on the current bar.
Calculation: Structure direction = initially neutral; change to bullish on a bullish break of structure and bearish on a bearish break of structure. A bullish break occurs when close > latest confirmed swing high AND previous close <= that same swing high AND the bullish market-bias setting is allowed AND, if the strong-close filter is enabled, high > low AND abs(close - open) >= a configurable fraction of (high - low). A bearish break uses close < latest confirmed swing low AND previous close >= that same swing low, the bearish market-bias setting, and the same optional strong-close filter. If both occur on one bar, bearish direction takes precedence.
Long: A swing high is confirmed AND its value >= the preceding confirmed swing high OR no preceding swing high exists.
Short: A swing high is confirmed AND its value < the preceding confirmed swing high.
Long: A swing low is confirmed AND its value >= the preceding confirmed swing low OR no preceding swing low exists.
Short: A swing low is confirmed AND its value < the preceding confirmed swing low.
Long: A bullish break of structure occurs.
Short: A bearish break of structure occurs.
Long: Low > high two bars earlier.
Short: High < low two bars earlier.
Long: Low < latest confirmed swing low AND close > latest confirmed swing low.
Short: High > latest confirmed swing high AND close < latest confirmed swing high.
Long: Structure direction is bullish or neutral.
Short: Structure direction is bearish.
Long: The last completed higher-timeframe close > its higher-timeframe simple moving average.
Short: The last completed higher-timeframe close <= its higher-timeframe simple moving average.
Long: Close <= the midpoint of the highest high and lowest low over a configurable lookback of last completed higher-timeframe bars.
Short: Close > the midpoint of the highest high and lowest low over a configurable lookback of last completed higher-timeframe bars.