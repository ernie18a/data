Calculation: Combined volume = sum of volume from both feeds
Calculation: Smoothed delta = EMA of the sum of signed volume proxies, where each proxy is volume if close ≥ open, otherwise −volume
Calculation: Combined-volume average = SMA of combined volume
Long: Smoothed delta > 0 AND smoothed delta > its previous value AND combined volume > combined-volume average AND VIX1D ≤ its previous value
Short: Smoothed delta < 0 AND smoothed delta < its previous value AND combined volume > combined-volume average AND VIX1D > its previous value
Exit: Long, smoothed delta < 0 OR close < combined-volume average OR time is 15:45 ET or later
Exit: Short, smoothed delta > 0 OR close > combined-volume average OR time is 15:45 ET or later