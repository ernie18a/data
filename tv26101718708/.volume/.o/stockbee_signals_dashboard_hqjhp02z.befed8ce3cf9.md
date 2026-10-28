Long: 7-bar SMA(close) / 65-bar SMA(close) > 1.05
Long: close / 126-bar SMA(close) > 1.10
Long: (close / 30-bar lowest close >= 1.20 OR close - 30-bar lowest close >= 20) AND close >= 3 AND min(volume of the previous 3 bars) >= 100000
Long: 7-bar SMA(close) / 65-bar SMA(close) > 1.05 AND round(close / 126-bar SMA(close), 2) > 1.05 AND ((close / 30-bar lowest close >= 1.20 OR close - 30-bar lowest close >= 20) AND close >= 3 AND min(volume of the previous 3 bars) >= 100000)
Short: 7-bar SMA(close) / 65-bar SMA(close) < 0.95
Short: close / 126-bar SMA(close) < 0.90
Short: (close / 30-bar highest close <= 0.80 OR 30-bar highest close - close >= 20) AND close >= 5 AND min(volume of the previous 3 bars) >= 100000