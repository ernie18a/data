Calculation: Volume burst = volume > SMA(volume, lookback) + k × standard deviation(volume, lookback)
Calculation: Hawkes intensity = exp(−ln(2) / half-life) × prior-bar intensity + (volume burst ? 1 : 0)
Calculation: Cluster active = Hawkes intensity > SMA(Hawkes intensity, 100) + k × standard deviation(Hawkes intensity, 100)
Long: Cluster active AND close − open > k × ATR(14) AND position is flat or short AND cooldown since last signal has elapsed AND current bar is confirmed
Short: Cluster active AND close − open < −k × ATR(14) AND position is flat or long AND cooldown since last signal has elapsed AND current bar is confirmed