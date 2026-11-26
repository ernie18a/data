Calculation: Negative-volume cumulative return = its prior value + (close - close[1]) / close[1] when volume < volume[1], otherwise its prior value; initial value is 0.
Calculation: Normalized negative-volume deviation = (Negative-volume cumulative return - EMA(Negative-volume cumulative return, shorter lookback)) / (highest(EMA(Negative-volume cumulative return, shorter lookback), longer lookback) - lowest(EMA(Negative-volume cumulative return, shorter lookback), longer lookback)).
Long: Normalized negative-volume deviation > 0 AND Normalized negative-volume deviation[1] < 0.
Short: Normalized negative-volume deviation < 0 AND Normalized negative-volume deviation[1] > 0.
Calculation: Long exit-pending state = false if Long exit-pending state[exit delay] is true; otherwise true if the long-entry condition is true; otherwise its prior value; initial value is false.
Calculation: Short exit-pending state = false if Short exit-pending state[exit delay] is true; otherwise true if the short-entry condition is true; otherwise its prior value; initial value is false.
Exit: long, Long exit-pending state[exit delay] is true.
Exit: short, Short exit-pending state[exit delay] is true.