Calculation: EMA ribbon score = +1 when the four EMAs, ordered from shortest to longest lookback, are strictly descending; -1 when strictly ascending; otherwise 0
Calculation: Volume-direction score = +1 when volume exceeds its moving average multiplied by a spike threshold and close > open; -1 when that volume condition holds and close < open; otherwise 0
Calculation: Signal-timeframe score = EMA ribbon score + RSI score + Volume-direction score, calculated on each of the four signal timeframes using completed bars, whether the timeframe is higher or lower than the chart timeframe
Calculation: Total confluence = sum of the four signal-timeframe scores
Long: any signal-timeframe score >= 2
Short: any signal-timeframe score <= -2
Long: Total confluence >= aligned threshold
Long: Total confluence >= lean threshold AND Total confluence < aligned threshold
Short: Total confluence <= -aligned threshold
Short: Total confluence <= -lean threshold AND Total confluence > -aligned threshold
Long: Total confluence >= aligned threshold AND previous Total confluence < aligned threshold AND (last fired direction is not short OR (neutral reset is not required OR Total confluence has reached the neutral zone since the last signal) AND bars since the last signal >= minimum bar gap)
Long: Total confluence >= lean threshold AND Total confluence < aligned threshold AND previous Total confluence is not in the lean-buy or aligned-buy range AND (last fired direction is not short OR (neutral reset is not required OR Total confluence has reached the neutral zone since the last signal) AND bars since the last signal >= minimum bar gap)
Short: Total confluence <= -aligned threshold AND previous Total confluence > -aligned threshold AND (last fired direction is not long OR (neutral reset is not required OR Total confluence has reached the neutral zone since the last signal) AND bars since the last signal >= minimum bar gap)
Short: Total confluence <= -lean threshold AND Total confluence > -aligned threshold AND previous Total confluence is not in the lean-sell or aligned-sell range AND (last fired direction is not long OR (neutral reset is not required OR Total confluence has reached the neutral zone since the last signal) AND bars since the last signal >= minimum bar gap)