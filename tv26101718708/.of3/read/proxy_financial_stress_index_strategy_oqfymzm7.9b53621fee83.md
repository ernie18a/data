Calculation: For each of six close series, normalized close = (T1 close sampled on chart bars, including the still-forming T1 bar in real time - SMA(sampled close, shared SMA lookback on chart bars)) / standard deviation(sampled close, shared standard-deviation lookback on chart bars)
Calculation: stress index = sum of each normalized close multiplied by its separate weight
Long: stress index crosses below threshold AND no position is open
Exit: long, bars since entry >= holding period