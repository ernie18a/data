Calculation: Network investment metric = square root of the absolute value of (miner revenue × hashrate) / max(network difficulty, 1), using the latest available lower-timeframe on-chain data
Calculation: Smoothed log relative value = moving average of log(close / network investment metric), using a shorter lookback than the z-score lookback
Calculation: Relative value z-score = (smoothed log relative value − its longer-lookback moving average) / its longer-lookback standard deviation; use 0 when standard deviation is 0
Long: Relative value z-score <= -1
Exit: long, Relative value z-score >= 2