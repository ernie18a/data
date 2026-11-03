Calculation: BinaryWave = smoothed sum of weighted votes on the configured indicator timeframe (which may be higher or lower than the chart timeframe), using its last completed bar: +weight if close is above its moving average, MACD is rising, OsMA and CCI are above zero, Momentum is above 100, RSI is above 50, or +DI is above -DI; −weight for the opposite comparison; zero when equal or the component weight is zero.
Calculation: BinaryWave change = current BinaryWave − previous BinaryWave on the indicator timeframe.
Calculation: Change standard deviation = population standard deviation of the recent BinaryWave changes, including the current change.
Long: BinaryWave change > the smaller volatility multiplier × Change standard deviation OR current BinaryWave > previous BinaryWave AND previous BinaryWave < the one before it.
Short: BinaryWave change < −(the smaller volatility multiplier × Change standard deviation) OR current BinaryWave < previous BinaryWave AND previous BinaryWave > the one before it.
Exit: Long, previous BinaryWave > current BinaryWave.
Exit: Short, previous BinaryWave < current BinaryWave.