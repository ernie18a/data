Calculation: volume z-score = (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback)
Calculation: spread z-score = ((high - low) - SMA(high - low, spread lookback)) / STDEV(high - low, spread lookback)
Long: volume z-score >= volume threshold AND spread z-score >= spread threshold * wide spread factor AND spread z-score > narrow spread threshold AND close >= open
Short: volume z-score >= volume threshold AND spread z-score >= spread threshold * wide spread factor AND spread z-score > narrow spread threshold AND close < open
Exit: long, volume z-score <= -(volume threshold * low volume factor) AND spread z-score >= spread threshold * wide spread factor
Exit: short, volume z-score <= -(volume threshold * low volume factor) AND spread z-score >= spread threshold * wide spread factor