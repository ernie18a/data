Calculation: JFATL = JMA-smoothed 39-bar FATL digital-filter value of applied OHLC price; calculate on the configured indicator timeframe and evaluate its last completed bar.
Calculation: JFATL change = current JFATL minus previous JFATL value.
Calculation: Change standard deviation = population standard deviation of the recent JFATL changes, using a lookback longer than one bar.
Long: JFATL change > lower threshold × Change standard deviation OR (current JFATL > previous JFATL AND previous JFATL < JFATL two bars earlier)
Short: JFATL change < −lower threshold × Change standard deviation OR (current JFATL < previous JFATL AND previous JFATL > JFATL two bars earlier)
Exit: long, previous JFATL > current JFATL
Exit: short, previous JFATL < current JFATL