Calculation: J2JMA = apply JMA smoothing twice in succession to the selected OHLC applied price, using separate parameter sets for each smoothing
Calculation: J2JMA change = current J2JMA − previous J2JMA
Calculation: Change standard deviation = population standard deviation of the most recent lookback of J2JMA changes, including the current change
Long: J2JMA change > the short-threshold multiplier × Change standard deviation OR current J2JMA > previous J2JMA AND previous J2JMA < the J2JMA value two bars earlier
Short: J2JMA change < −(short-threshold multiplier × Change standard deviation) OR current J2JMA < previous J2JMA AND previous J2JMA > the J2JMA value two bars earlier
Exit: long, J2JMA change < 0 OR J2JMA change < −(short-threshold multiplier × Change standard deviation)
Exit: short, J2JMA change > 0 OR J2JMA change > short-threshold multiplier × Change standard deviation