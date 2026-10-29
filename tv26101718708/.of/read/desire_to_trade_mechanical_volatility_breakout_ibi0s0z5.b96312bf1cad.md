Calculation: Prior range high = highest high over the lookback bars, excluding the current bar
Calculation: Prior range low = lowest low over the lookback bars, excluding the current bar
Calculation: Range size = prior range high - prior range low
Calculation: Relative volume = current volume / average volume over a lookback
Calculation: Long risk = max(entry price - prior range low, minimum tick size)
Calculation: Short risk = max(prior range high - entry price, minimum tick size)
Calculation: Long runner stop = the highest value reached so far of the greater of prior range low and the selected trail (a shorter-lookback EMA or close minus an ATR multiple)
Calculation: Short runner stop = the lowest value reached so far of the lesser of prior range high and the selected trail (a shorter-lookback EMA or close plus an ATR multiple)
Long: range size is between a lower and upper ATR multiple AND close > the longer-lookback stock EMA AND benchmark close > benchmark EMA AND ATR > its average over a longer lookback AND relative volume >= a threshold AND (close > prior range high OR a previously armed buy stop at prior range high is reached while flat)
Short: range size is between a lower and upper ATR multiple AND close < the longer-lookback stock EMA AND benchmark close < benchmark EMA AND ATR > its average over a longer lookback AND relative volume >= a threshold AND (close < prior range low OR a previously armed sell stop at prior range low is reached while flat)
Exit: long, low <= prior range low OR high >= entry price + full-exit risk multiple * long risk OR high >= entry price + partial-profit risk multiple * long risk OR low <= long runner stop OR close < the longer-lookback stock EMA OR short conditions are met
Exit: short, high >= prior range high OR low <= entry price - full-exit risk multiple * short risk OR low <= entry price - partial-profit risk multiple * short risk OR high >= short runner stop OR close > the longer-lookback stock EMA OR long conditions are met