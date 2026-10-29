Calculation: EMA bias (%) = (shorter-lookback EMA of close − longer-lookback EMA of close) / longer-lookback EMA of close × 100
Calculation: Upper shadow (%) = (high − close) / close × 100
Calculation: Stop price = entry price × (1 − the fixed stop-loss percentage for the entry signal); when close / entry price reaches the break-even threshold, raise the stop to at least the entry price; when it reaches the higher profit threshold, raise the stop to at least entry price + half the gain from entry to close
Long: EMA bias is between its lower and upper bounds AND upper shadow is below its maximum AND volume is between its minimum and maximum multiples of its moving average AND close > prior bar close AND EMA bias is positive AND ((open > short-lookback EMA AND low <= long-lookback EMA AND close > short-lookback EMA) OR (open > long-lookback EMA AND open < short-lookback EMA AND low <= long-lookback EMA AND close > short-lookback EMA) OR (open > short-lookback EMA AND low <= short-lookback EMA AND close > short-lookback EMA))
Exit: long, close <= stop price
Exit: long, close <= longer-lookback EMA
Exit: long, held-bar count reaches its time limit AND highest high over its lookback / entry price is below its minimum profit threshold
Exit: long, close / entry price reaches the first profit-taking threshold applicable to the entry signal
Exit: long, close / entry price reaches the second profit-taking threshold applicable to the entry signal