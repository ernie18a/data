Calculation: volume ratio = volume / simple moving average of volume
Calculation: close-to-close percent change = (close - previous bar close) / previous bar close × 100
Calculation: Bollinger Band width = (upper band - lower band) / middle band, using the same lookback for all three bands
Calculation: five-bar momentum = (close - close five bars ago) / close five bars ago × 100
Calculation: signal score = 2 if volume ratio > high volume threshold, else 1 if volume ratio > low volume threshold, else 0; plus 2 if close-to-close percent change > high change threshold, else 1 if it > low change threshold, else 0; plus 1 if short-term EMA > longer-term EMA; plus 1 if close > short-term EMA; plus 1 if Bollinger Band width < width threshold; plus 1 if five-bar momentum > momentum threshold
Long: no open position AND close > short-term EMA AND RSI < RSI maximum AND signal score >= minimum score
Exit: long, close < short-term EMA AND five-bar momentum < negative momentum threshold OR price reaches the trailing stop, activated at entry price plus a close-based percentage distance and trailing the favorable high by a close-based percentage offset