Calculation: percent change = ROC(close, prior bar)
Calculation: distribution day = (percent change <= negative drop threshold AND volume > volume[prior bar]) OR (volume > volume[prior bar] AND close <= midpoint of the bar's high-low range) OR (volume > SMA(volume, volume lookback) AND percent change < stalling-rise threshold)
Calculation: valid distribution-day count = number of distribution-day bars among the current and prior count-lookback bars for which no more recent close in that lookback is at least that bar's close multiplied by (1 + invalidation-rise threshold / 100)
Short: distribution day
Short: valid distribution-day count >= danger-count threshold