Calculation: RSI input = if (close − SMA(close, z-score lookback)) / StDev(close, z-score lookback) != 0 then StDev(close, z-score lookback) else 1
Calculation: transformed RSI = RSI(RSI input, RSI lookback)
Calculation: smoothed transformed RSI = selected MA(transformed RSI, smoothing lookback, MA type)
Calculation: long exit threshold = oversold level + selected exit fraction × (overbought level − oversold level)
Calculation: short exit threshold = overbought level − selected exit fraction × (overbought level − oversold level)
Long: selected signal mode compares smoothed transformed RSI with the midline AND smoothed transformed RSI > midline
Short: selected signal mode compares smoothed transformed RSI with the midline AND smoothed transformed RSI < midline
Long: selected signal mode compares transformed RSI with smoothed transformed RSI AND transformed RSI > smoothed transformed RSI
Short: selected signal mode compares transformed RSI with smoothed transformed RSI AND transformed RSI < smoothed transformed RSI
Long: selected entry mode uses the midline crossover AND crossover(smoothed transformed RSI, midline)
Short: selected entry mode uses the midline crossover AND crossunder(smoothed transformed RSI, midline)
Long: selected entry mode uses the RSI moving-average crossover AND crossover(transformed RSI, smoothed transformed RSI)
Short: selected entry mode uses the RSI moving-average crossover AND crossunder(transformed RSI, smoothed transformed RSI)
Long: selected entry mode uses RSI overbought/oversold levels AND crossunder(transformed RSI, oversold level)
Short: selected entry mode uses RSI overbought/oversold levels AND crossover(transformed RSI, overbought level)
Long: selected entry mode uses smoothed RSI overbought/oversold levels AND crossunder(smoothed transformed RSI, oversold level)
Short: selected entry mode uses smoothed RSI overbought/oversold levels AND crossover(smoothed transformed RSI, overbought level)
Exit: long, open-position profit percentage > profit threshold
Exit: short, open-position profit percentage > profit threshold
Exit: long, selected entry mode uses RSI overbought/oversold levels AND long exit threshold < overbought level AND crossover(transformed RSI, long exit threshold)
Exit: short, selected entry mode uses RSI overbought/oversold levels AND short exit threshold > oversold level AND crossunder(transformed RSI, short exit threshold)
Exit: long, selected entry mode uses smoothed RSI overbought/oversold levels AND long exit threshold < overbought level AND crossover(smoothed transformed RSI, long exit threshold)
Exit: short, selected entry mode uses smoothed RSI overbought/oversold levels AND short exit threshold > oversold level AND crossunder(smoothed transformed RSI, short exit threshold)