Calculation: Lagged close = close of the last completed bar on the selected timeframe
Calculation: Ratio = log(current close / lagged close)
Calculation: Short average = selected moving average of the ratio using the shorter lookback
Calculation: Long average = the same selected moving average of the ratio using a longer lookback
Calculation: Z-score = (short average − long average) / standard deviation of the long average over a lookback between the shorter and longer lookbacks
Calculation: Signal = long when Z-score < −threshold; short when Z-score > threshold; otherwise clear. Count each bar with a long or short signal; clear the signal when the counter reaches the configured tick limit, then reset the counter.
Long: Z-score < −threshold AND prior signal ≠ long
Short: Z-score > threshold AND prior signal ≠ short
Exit: long or short, prior signal is long or short AND (−threshold ≤ Z-score ≤ threshold OR prior directional-signal bar count equals the configured tick limit)