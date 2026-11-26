Calculation: RSI = RSI(selected price field, RSI lookback)
Calculation: RSI average = SMA(RSI, RSI-average lookback)
Calculation: Long RSI setup = (Long RSI setup[1] AND NOT (RSI average - RSI > retest threshold)) OR (RSI - RSI average > crossover threshold); initially false
Calculation: Long RSI retest = Long RSI setup AND (Long RSI retest[1] OR (RSI - RSI average < retest threshold)); initially false
Calculation: Short RSI setup = (Short RSI setup[1] AND NOT (RSI - RSI average > retest threshold)) OR (RSI average - RSI > crossover threshold); initially false
Calculation: Short RSI retest = Short RSI setup AND (Short RSI retest[1] OR (RSI average - RSI < retest threshold)); initially false
Calculation: Long RSI trigger = (Long RSI retest AND RSI - RSI average > crossover threshold) OR (RSI - RSI average > instant-signal threshold)
Calculation: Short RSI trigger = (Short RSI retest AND RSI average - RSI > crossover threshold) OR (RSI average - RSI > instant-signal threshold)
Calculation: Long RSI zone = (Long RSI trigger OR Long RSI zone[1]) AND NOT Short RSI trigger; initially false
Calculation: Short RSI zone = (Short RSI trigger OR Short RSI zone[1]) AND NOT Long RSI trigger; initially false
Calculation: Long RSI signal = Long RSI zone AND Short RSI zone[1]
Calculation: Short RSI signal = Short RSI zone AND Long RSI zone[1]
Calculation: Long RSI extreme confirmation = (Long RSI extreme confirmation[1] AND NOT Short RSI signal) OR (RSI <= oversold threshold); initially false
Calculation: Short RSI extreme confirmation = (Short RSI extreme confirmation[1] AND NOT Long RSI signal) OR (RSI >= overbought threshold); initially false
Calculation: BBWP = BBWP(selected price field, width lookback, percentile lookback, basis average type)
Calculation: BBWP average = selected moving average(BBWP, BBWP-average lookback, BBWP-average type)
Calculation: BBWP confirmation = BBWP moving average enabled AND (BBWP - BBWP average > BBWP confirmation threshold)
Calculation: Long confirmed trigger = Long RSI zone AND (Long RSI extreme confirmation OR BBWP confirmation) AND RSI > RSI average AND RSI average > oversold threshold
Calculation: Short confirmed trigger = Short RSI zone AND (Short RSI extreme confirmation OR BBWP confirmation) AND RSI < RSI average AND RSI average < overbought threshold
Calculation: Long confirmed zone = (Long confirmed zone[1] OR Long confirmed trigger) AND NOT Short confirmed trigger; initially false
Calculation: Short confirmed zone = (Short confirmed zone[1] OR Short confirmed trigger) AND NOT Long confirmed trigger; initially false
Calculation: Trend average = selected moving average(selected price field, trend-average lookback, trend-average type)
Calculation: Trend long onset = (Long confirmed zone AND selected price field > Trend average) AND NOT (Long confirmed zone[1] AND selected price field[1] > Trend average[1])
Calculation: Trend short onset = (Short confirmed zone AND selected price field < Trend average) AND NOT (Short confirmed zone[1] AND selected price field[1] < Trend average[1])
Calculation: Trend long zone = (Trend long zone[1] OR Trend long onset) AND NOT Trend short onset; initially false
Calculation: Trend short zone = (Trend short zone[1] OR Trend short onset) AND NOT Trend long onset; initially false
Long: Long RSI signal
Short: Short RSI signal
Long: Long confirmed zone AND Short confirmed zone[1]
Short: Short confirmed zone AND Long confirmed zone[1]
Long: Trend long zone AND NOT Trend long zone[1]
Short: Trend short zone AND NOT Trend short zone[1]
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + take-profit percentage)
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - take-profit percentage)