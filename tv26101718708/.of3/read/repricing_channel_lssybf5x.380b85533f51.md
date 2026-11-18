Calculation: T1 block range = max(highest high − lowest low of chart bars in the T1 block, range floor parameter)
Calculation: T1 block volume = max(sum of chart-bar volume in the T1 block, volume floor parameter)
Calculation: T1 block efficiency = T1 block range / T1 block volume
Calculation: range ratio = last completed T1 block range / average range of the comparison lookback preceding completed T1 blocks
Calculation: volume ratio = last completed T1 block volume / average volume of the comparison lookback preceding completed T1 blocks
Calculation: efficiency ratio = last completed T1 block efficiency / average efficiency of the comparison lookback preceding completed T1 blocks
Calculation: Repricing = on chart bars when a new T1 block starts, the last completed T1 block has at least the comparison lookback preceding completed T1 blocks, their average range, volume, and efficiency are positive, efficiency ratio >= minimum efficiency ratio, range ratio >= minimum range ratio, and (volume cap is disabled OR volume ratio <= maximum volume ratio)
Calculation: repricing bias = on chart bars when a T1 block completes, the mean direction of the most recent channel lookback repricing T1 blocks, where direction is +1 if close >= open and −1 otherwise; bias is 1 if the mean > bias threshold, −1 if the mean < −bias threshold, and 0 otherwise, held until the next T1 block completes
Long: When a new T1 block starts, mark the preceding T1 block's last chart bar if Repricing AND its close >= its open
Short: When a new T1 block starts, mark the preceding T1 block's last chart bar if Repricing AND its close < its open
Long: repricing bias = 1
Short: repricing bias = −1