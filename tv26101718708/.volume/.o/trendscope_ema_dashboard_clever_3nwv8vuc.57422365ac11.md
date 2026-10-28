Calculation: Fast EMA = exponential moving average of close with the shortest lookback
Calculation: Medium EMA = exponential moving average of close with the second-shortest lookback
Calculation: Slow EMA = exponential moving average of close with the second-longest lookback
Calculation: Long EMA = exponential moving average of close with the longest lookback
Long: Fast EMA > Medium EMA > Slow EMA > Long EMA AND at least one of these inequalities was false on the prior bar
Short: Fast EMA < Medium EMA < Slow EMA < Long EMA AND at least one of these inequalities was false on the prior bar
Exit: Long, Fast EMA > Medium EMA > Slow EMA > Long EMA was true on the prior bar AND neither Fast EMA > Medium EMA > Slow EMA > Long EMA nor Fast EMA < Medium EMA < Slow EMA < Long EMA is true on this bar
Exit: Short, Fast EMA < Medium EMA < Slow EMA < Long EMA was true on the prior bar AND neither Fast EMA > Medium EMA > Slow EMA > Long EMA nor Fast EMA < Medium EMA < Slow EMA < Long EMA is true on this bar