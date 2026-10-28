Calculation: Combined volume = SPY volume + ES volume on the current chart-timeframe bar.
Calculation: Smoothed volume delta = EMA of the sum of SPY and ES volume, each positive when that instrument's close is at or above its open and negative otherwise.
Long: Time is 09:30–10:30 or 14:00–15:45 ET AND combined volume > its simple moving average AND smoothed volume delta >= 0 AND smoothed volume delta > its previous value AND VIX1D <= its previous value.
Short: Time is 09:30–10:30 or 14:00–15:45 ET AND combined volume > its simple moving average AND smoothed volume delta < 0 AND smoothed volume delta < its previous value AND VIX1D > its previous value.
Exit: long, smoothed volume delta < 0 OR combined volume < its simple moving average OR time >= 15:45 ET.
Exit: short, smoothed volume delta > 0 OR combined volume < its simple moving average OR time >= 15:45 ET.