Calculation: ATR trailing stop = Recursively set the stop to the maximum of its prior value and close minus the ATR multiplied by a sensitivity factor when both current and prior close are above the prior stop; otherwise, if both are below, use the minimum of the prior stop and close plus ATR times the sensitivity factor; otherwise use close minus ATR times the sensitivity factor when close is above the prior stop, or close plus ATR times the sensitivity factor when it is not. Initialize the prior stop to zero.
Calculation: Schaff Trend Cycle = Apply a stochastic normalization over a lookback to the difference between a fast EMA and a slower EMA, then apply a second stochastic normalization over the same lookback; smooth each normalized series recursively with an alpha parameter, and use the second smoothed series as the cycle value.
Calculation: Hull moving average = Weighted moving average of twice the weighted moving average of close over half the lookback minus the weighted moving average of close over the full lookback, over the square root of the lookback.
Long: Close crosses above the ATR trailing stop and close is above it
Short: Close crosses below the ATR trailing stop and close is below it
Long: Schaff Trend Cycle value rises, is below 25, and the Hull moving average is above its value two bars earlier, and the most recent ATR trailing-stop buy signal is later than the most recent sell signal
Short: Schaff Trend Cycle value falls, is above 75, and the Hull moving average is below its value two bars earlier, and the most recent ATR trailing-stop sell signal is later than the most recent buy signal
Long: Schaff Trend Cycle value is rising
Short: Schaff Trend Cycle value is not rising
Long: Schaff Trend Cycle value two bars earlier is below its value three bars earlier, its value one bar earlier is below its value two bars earlier, its current value is below 25, and its value three bars earlier is at least its value two bars earlier
Short: Schaff Trend Cycle value two bars earlier is above its value three bars earlier, its value one bar earlier is above its value two bars earlier, its current value is above 75, and its value three bars earlier is at most its value two bars earlier
Long: Hull moving average crosses above its value two bars earlier
Short: Hull moving average crosses below its value two bars earlier
Exit: Long, close is below entry price times one minus the stop-loss percentage
Exit: Short, close is above entry price times one plus the stop-loss percentage
Exit: Long, high reaches entry price times one plus a take-profit percentage
Exit: Short, low reaches entry price times one minus a take-profit percentage