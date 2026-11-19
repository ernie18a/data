Calculation: Gaussian filter(source, length) = let b = 2.415 × (1 − cos(2π / length)) / (cos(2π / length) − 1 + √2) and a = −b + √(b² + 2b); initialize output to source, then output = a × source + (1 − a) × previous output
Calculation: Smoothed close = Gaussian filter(MEDIAN(close, median smoothing lookback), Gaussian filter length)
Calculation: Smoothed volume = Gaussian filter(MEDIAN(volume, median smoothing lookback), Gaussian filter length)
Calculation: Liquidity impact = if Smoothed close × Smoothed volume = 0 then 0 else (Smoothed close − Smoothed close[1]) / (Smoothed close × Smoothed volume)
Calculation: Liquidity z-score = (Liquidity impact − SMA(Liquidity impact, calculation window)) / (if STDEV(Liquidity impact, calculation window) = 0 then 0.0001 else STDEV(Liquidity impact, calculation window))
Calculation: Price-volume ROC divergence = ROC(Smoothed close, calculation window) − ROC(SMA(Smoothed volume, calculation window), calculation window)
Calculation: Scaled imbalance = (Liquidity z-score × Price-volume ROC divergence) / (if STDEV(Liquidity z-score × Price-volume ROC divergence, twice the calculation window) = 0 then 1 else STDEV(Liquidity z-score × Price-volume ROC divergence, twice the calculation window))
Calculation: Macro signal = MEDIAN(Gaussian filter(Scaled imbalance, signal smoothing length), macro median lookback)
Calculation: ALEX score = if HIGHEST(Macro signal, scaling lookback) − LOWEST(Macro signal, scaling lookback) = 0 then 0 else 100 × tanh((200 × (Macro signal − LOWEST(Macro signal, scaling lookback)) / (HIGHEST(Macro signal, scaling lookback) − LOWEST(Macro signal, scaling lookback)) − 100) / 100)
Calculation: Upper extreme = min(extreme cap, extreme baseline + STDEV(ALEX score, scaling lookback) × volatility sensitivity × deviation factor)
Calculation: Lower extreme = max(−extreme cap, −extreme baseline − STDEV(ALEX score, scaling lookback) × volatility sensitivity × deviation factor)
Calculation: Upper trigger = trigger fraction × Upper extreme
Calculation: Lower trigger = trigger fraction × Lower extreme
Long: ALEX score < Lower extreme OR (ALEX score > Upper trigger AND ALEX score <= Upper extreme)
Short: ALEX score > Upper extreme OR (ALEX score < Lower trigger AND ALEX score >= Lower extreme)