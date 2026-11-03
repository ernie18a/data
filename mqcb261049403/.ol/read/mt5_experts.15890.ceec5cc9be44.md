Calculation: Buy points = for each configured timeframe except the longest, add one for each of these seven strict comparisons being true: current forming bar open, high, low, close, (high + low) / 2, (high + low + close) / 3, and (high + low + 2 × close) / 4 is greater than the corresponding value on the immediately preceding completed bar; otherwise add zero. The configured timeframes may be higher or lower than the chart timeframe.
Calculation: Sell points = for each of those comparisons, add one when it is false, including when the values are equal.
Calculation: Buy percentage = floor(100 × buy points / (buy points + sell points)).
Calculation: Sell percentage = floor(100 × sell points / (buy points + sell points)).
Long: no position is open AND buy percentage > opening threshold
Short: no position is open AND sell percentage > opening threshold
Exit: Long, buy percentage < closing threshold
Exit: Short, sell percentage < closing threshold