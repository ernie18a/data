Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than the fast EMA
Calculation: VWAP = volume-weighted average price
Calculation: RVOL = volume divided by its moving average over a lookback period
Calculation: Upper wick = high minus the greater of open and close
Calculation: Body size = absolute difference between open and close
Long: Previous completed close crosses above the highest high over a lookback period ending one bar before the previous completed bar AND previous completed close is above VWAP AND fast EMA is above slow EMA AND previous completed RVOL is above the entry threshold
Exit: long, previous completed close crosses below fast EMA
Exit: long, upper wick of the previous completed bar is greater than a multiple of its body size AND previous completed RVOL is above the exhaustion threshold AND previous completed close has not crossed below fast EMA