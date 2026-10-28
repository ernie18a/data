Calculation: Normalized value = (value − rolling mean) / rolling standard deviation, or 0 when the standard deviation is 0; use the same lookback for every normalization.
Calculation: Pi-cycle measure = 2 × shorter rolling mean of close / longer rolling mean of close − 1.
Calculation: Log-price deviation = log(close) − rolling linear regression of log(close).
Calculation: Price-to-M2 = close / M2 source; the source defaults to close.
Calculation: Volume momentum = percentage change in volume over a shorter lookback.
Calculation: Smoothed oscillator = EMA of a weighted sum of normalized Pi-cycle measure, MVRV, NUPL, Puell, Stock-to-Flow, Risk Wave, log-price deviation, price-to-M2, ISM/PMI, and volume momentum. Each source defaults to close.
Calculation: Overheated threshold = rolling mean of the smoothed oscillator + a multiple of its rolling standard deviation.
Long: Smoothed oscillator < 0
Short: Smoothed oscillator > overheated threshold