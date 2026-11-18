Calculation: Predicted price = intercept + slope × volume, where intercept and slope are the least-squares regression of close on volume over a lookback
Calculation: MACD line = EMA(predicted price, fast lookback) − EMA(predicted price, slow lookback)
Calculation: MACD signal line = EMA(MACD line, signal smoothing lookback)
Long: Predicted price crosses above close
Long: Predicted price crosses above WMA(predicted price, linear lookback) AND MACD signal line < MACD line AND MACD line is rising over a lookback
Short: Predicted price crosses below close
Short: MACD line is falling over a lookback AND MACD line < MACD signal line AND low is falling over a lookback
Exit: Long, predicted price crosses below close