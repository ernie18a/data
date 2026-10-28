Calculation: Bollinger bands = simple moving average of close plus/minus a configurable multiple of close’s standard deviation, using the same lookback for both; compare each close with the bands calculated for its own bar.
Calculation: MACD line = shorter-lookback EMA of close minus longer-lookback EMA of close; MACD signal line = EMA of the MACD line.
Calculation: Volume moving average = simple moving average of volume.
Long: Previous bar close < previous bar lower Bollinger band AND current close > current lower Bollinger band AND MACD line > MACD signal line AND volume >= a configurable multiple of the volume moving average
Short: Previous bar close > previous bar upper Bollinger band AND current close < current upper Bollinger band AND MACD line < MACD signal line AND volume >= a configurable multiple of the volume moving average
Exit: Long, low <= entry price * (1 - configurable stop-loss fraction) OR high >= entry price * (1 + configurable take-profit fraction)
Exit: Short, high >= entry price * (1 + configurable stop-loss fraction) OR low <= entry price * (1 - configurable take-profit fraction)