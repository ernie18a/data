Calculation: Upward score = add a progressively larger weight for each true comparison in this chain: close > shortest moving average; each moving average > the next longer moving average, ending with the longest pair. Use seven chart-timeframe moving averages with progressively longer lookbacks; the weights increase toward the longer averages.
Calculation: Strength = sum of upward scores over a lookback window.
Calculation: Strength average = a moving average of Strength with a longer lookback than the score-sum window.
Long: Strength > Strength average AND previous Strength <= previous Strength average AND Strength > Strength at a prior offset bar AND datetime is within the configured start and end times
Short: Strength < Strength average AND previous Strength >= previous Strength average AND Strength < Strength at a prior offset bar AND datetime is within the configured start and end times
Exit: long, Strength < Strength average AND previous Strength >= previous Strength average AND Strength < Strength at a prior offset bar
Exit: short, Strength > Strength average AND previous Strength <= previous Strength average AND Strength > Strength at a prior offset bar