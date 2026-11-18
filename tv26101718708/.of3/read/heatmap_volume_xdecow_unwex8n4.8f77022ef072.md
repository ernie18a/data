Calculation: volume deviation score = (volume - SMA(volume, moving-average lookback)) / standard deviation(volume, standard-deviation lookback)
Long: close > open AND volume deviation score > extra-high threshold
Long: close > open AND volume deviation score <= extra-high threshold AND volume deviation score > high threshold
Long: close > open AND volume deviation score <= high threshold AND volume deviation score > medium threshold
Short: close < open AND volume deviation score > extra-high threshold
Short: close < open AND volume deviation score <= extra-high threshold AND volume deviation score > high threshold
Short: close < open AND volume deviation score <= high threshold AND volume deviation score > medium threshold