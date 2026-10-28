Calculation: Prior range high = highest high over the accumulation lookback, excluding the current bar
Calculation: Prior range low = lowest low over the accumulation lookback, excluding the current bar
Calculation: Accumulation threshold = prior range low + a fraction of the prior range width
Calculation: Chandelier Exit = highest high over its lookback minus an ATR multiple
Calculation: Stop price = the lower of the Chandelier Exit and the signal close minus an ATR multiple
Calculation: Profit target = entry price plus a fixed multiple of the risk from entry price to stop price
Long: close > accumulation threshold AND close <= prior range high AND volume > previous bar volume AND previous bar volume > volume two bars ago AND volume > its moving average times a threshold AND short-term EMA > longer-term EMA AND close > long-term SMA AND stop price < close AND no open position
Exit: long, low <= stop price OR high >= profit target