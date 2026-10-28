Calculation: Net pressure = volume × ((close − low) − (high − close)) / max(high − low, minimum tick)
Calculation: Maximum down-candle volume = maximum volume in the prior lookback bars whose close is below the preceding bar’s close; use 0 if none
Calculation: Maximum up-candle volume = maximum volume in the prior lookback bars whose close is above the preceding bar’s close; use 0 if none
Calculation: Net-pressure EMA = exponential moving average of net pressure
Long: close > previous close AND volume > maximum down-candle volume AND net pressure > net-pressure EMA
Short: close < previous close AND volume > maximum up-candle volume AND net pressure < net-pressure EMA