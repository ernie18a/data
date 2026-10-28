Calculation: RSI = Wilder RSI of close, on the selected RSI timeframe; use its last completed bar in non-repainting higher-timeframe mode, otherwise its current bar
Calculation: Signal line = selected moving average of RSI, using the same timeframe and bar as RSI
Calculation: Bull regime = lowest RSI over the regime lookback >= bull floor AND highest RSI over the regime lookback > bear ceiling
Calculation: Bear regime = highest RSI over the regime lookback <= bear ceiling AND lowest RSI over the regime lookback < bull floor
Calculation: Bull score = count of these true conditions: RSI > 50; RSI > signal line; signal line > 50; RSI minus RSI from the slope lookback > flat threshold; bull regime
Long: RSI crosses above signal line AND RSI >= 50
Long: RSI crosses above 50
Long: bull regime AND RSI < signal line
Long: bull regime AND previous bar was not in a bull regime
Long: bull score >= 4
Long: confirmed RSI pivot low is higher than the previous RSI pivot low AND its corresponding price low is lower than the previous price pivot low, with the pivots separated by a number of bars within the configured bounds
Long: confirmed RSI pivot low is lower than the previous RSI pivot low AND its corresponding price low is higher than the previous price pivot low, with the pivots separated by a number of bars within the configured bounds
Short: RSI crosses below signal line AND RSI < 50
Short: RSI crosses below 50
Short: bear regime AND RSI > signal line
Short: bear regime AND previous bar was not in a bear regime
Short: bull score <= 1
Short: confirmed RSI pivot high is lower than the previous RSI pivot high AND its corresponding price high is higher than the previous price high, with the pivots separated by a number of bars within the configured bounds
Short: confirmed RSI pivot high is higher than the previous RSI pivot high AND its corresponding price high is lower than the previous price high, with the pivots separated by a number of bars within the configured bounds
Exit: long, RSI crosses below the overbought level
Exit: short, RSI crosses above the oversold level