Calculation: EMA = exponential moving average of close
Calculation: RSI = relative strength index
Calculation: MACD histogram = difference between the MACD line and its signal line
Calculation: Phase low = lowest low over the setup lookback
Calculation: Phase high = highest high over the setup lookback
Calculation: Volume average = simple moving average of volume over the volume lookback
Calculation: Recent pivot high/low = latest confirmed high/low pivot using the pivot lookback on both sides
Long: After a bullish candle body crosses above the EMA, RSI was below its oversold threshold within the setup memory and the MACD histogram was rising within that memory, and the cooldown has elapsed; while waiting for a retest, low <= the EMA value at the cross + EMA tolerance AND close > that EMA value
Short: After a bearish candle body crosses below the EMA, RSI was above its overbought threshold within the setup memory and the MACD histogram was falling within that memory, and the cooldown has elapsed; while waiting for a retest, high >= the EMA value at the cross - EMA tolerance AND close < that EMA value
Long: low < the latest confirmed pivot low AND close > that pivot low AND low < prior low AND volume > volume average * volume threshold
Short: high > the latest confirmed pivot high AND close < that pivot high AND high > prior high AND volume > volume average * volume threshold
Long: The middle low of the latest three lows is below both adjacent lows, volume one bar earlier > volume average one bar earlier * volume threshold, and current low < the middle low AND close > the middle low AND current volume > volume average * volume threshold
Short: The middle high of the latest three highs is above both adjacent highs, volume one bar earlier > volume average one bar earlier * volume threshold, and current high > the middle high AND close < the middle high AND current volume > volume average * volume threshold
Calculation: Stop price = phase low for a long setup or phase high for a short setup
Calculation: Target price = entry price plus (long) or minus (short) absolute entry-to-stop distance multiplied by the risk/reward parameter
Exit: Long, low <= stop price OR high >= target price OR bars since entry >= maximum holding bars
Exit: Short, high >= stop price OR low <= target price OR bars since entry >= maximum holding bars