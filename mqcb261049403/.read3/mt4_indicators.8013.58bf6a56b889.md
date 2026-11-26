Long: Force Index(close, volume) > Force Index(close, volume)[1] AND crosses below zero
Long: Force Index(close, volume) > MAX(Force Index(close, volume), lookback)[1]
Short: Force Index(close, volume) < Force Index(close, volume)[1] AND crosses above zero
Short: Force Index(close, volume) < MIN(Force Index(close, volume), lookback)[1]