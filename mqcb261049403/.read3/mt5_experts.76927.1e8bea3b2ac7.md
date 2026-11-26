Calculation: Range high = highest(high, lookback previous completed chart bars), sampled at the first eligible tick at or after start time
Calculation: Range low = lowest(low, lookback previous completed chart bars), sampled at the first eligible tick at or after start time
Calculation: Range width = range high − range low
Calculation: Target risk = account balance × risk percentage / 100
Calculation: Initial risk distance = absolute difference between entry price and the opposite range boundary
Calculation: Position R = position-side favorable price change / initial risk distance
Calculation: R-level price(r) = entry price + position direction × initial risk distance × r, where direction is 1 for long and −1 for short
Calculation: Sized volume = broker-normalized volume from target risk, one-lot risk to the initial stop, and broker volume step, minimum, and maximum
Calculation: Sized-volume risk = absolute loss for the sized volume between entry price and the initial stop
Calculation: Minimum-lot risk overshoot = 100 × (sized-volume risk / target risk − 1)
Long: server time is at or after start time and before end time AND the range is active and has not been consumed or rejected AND range width ≥ minimum ATR multiplier × ATR(ATR period, T1, last completed bar sampled at range establishment) AND range width ≤ maximum ATR multiplier × ATR(ATR period, T1, last completed bar sampled at range establishment) AND (breakout mode is touch AND ask ≥ range high OR breakout mode is completed-bar close AND, on a new chart bar, close[1] > range high) AND no successful entry has occurred for this symbol during the server day AND nonnegative committed risk from other symbols + target risk ≤ account balance × daily risk limit / 100 + risk-comparison tolerance AND one-lot risk to the initial stop is computable and positive AND (minimum-lot skip is disabled OR minimum-lot risk overshoot ≤ minimum-lot overshoot tolerance)
Short: server time is at or after start time and before end time AND the range is active and has not been consumed or rejected AND range width ≥ minimum ATR multiplier × ATR(ATR period, T1, last completed bar sampled at range establishment) AND range width ≤ maximum ATR multiplier × ATR(ATR period, T1, last completed bar sampled at range establishment) AND (breakout mode is touch AND bid ≤ range low OR breakout mode is completed-bar close AND, on a new chart bar, close[1] < range low) AND no successful entry has occurred for this symbol during the server day AND nonnegative committed risk from other symbols + target risk ≤ account balance × daily risk limit / 100 + risk-comparison tolerance AND one-lot risk to the initial stop is computable and positive AND (minimum-lot skip is disabled OR minimum-lot risk overshoot ≤ minimum-lot overshoot tolerance)
Exit: long, current price ≤ range low
Exit: short, current price ≥ range high
Exit: long, fixed target is enabled AND current price ≥ R-level price(target R)
Exit: short, fixed target is enabled AND current price ≤ R-level price(target R)
Exit: long, break-even is enabled AND current price ≤ R-level price(break-even target R) after price has reached R-level price(break-even trigger R) and the stop modification succeeds
Exit: short, break-even is enabled AND current price ≥ R-level price(break-even target R) after price has reached R-level price(break-even trigger R) and the stop modification succeeds
Exit: long, partial close is enabled AND Position R ≥ partial-close trigger R AND the partial volume can be split within broker volume limits AND the partial close has not already been executed
Exit: short, partial close is enabled AND Position R ≥ partial-close trigger R AND the partial volume can be split within broker volume limits AND the partial close has not already been executed
Exit: long, server time is at or after end time on an incoming tick
Exit: short, server time is at or after end time on an incoming tick