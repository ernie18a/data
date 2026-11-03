Calculation: Volume burst = volume > rolling mean(volume, lookback) + multiplier × rolling standard deviation(volume, same lookback)
Calculation: Hawkes intensity = decay × prior-bar intensity + (volume burst ? 1 : 0), where decay = exp(−ln(2) / half-life)
Calculation: Cluster active = Hawkes intensity > rolling mean(Hawkes intensity, lookback) + multiplier × rolling standard deviation(Hawkes intensity, same lookback)
Long: Cluster active AND close − open > strength multiplier × ATR AND position is flat or short AND bars since last signal ≥ cooldown length
Short: Cluster active AND close − open < −strength multiplier × ATR AND position is flat or long AND bars since last signal ≥ cooldown length