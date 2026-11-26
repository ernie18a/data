Calculation: recent support touch = low <= low of last completed T1 bar * (1 + proximity parameter) has been true on the current or any of the previous touch-lookback number of chart bars
Calculation: recent resistance touch = high >= high of last completed T1 bar * (1 - proximity parameter) has been true on the current or any of the previous touch-lookback number of chart bars
Long: recent support touch AND close crosses above EMA(close, EMA lookback parameter)
Long: recent support touch AND close does not cross above EMA(close, EMA lookback parameter)
Short: recent resistance touch AND close crosses below EMA(close, EMA lookback parameter)
Short: recent resistance touch AND close does not cross below EMA(close, EMA lookback parameter)
Exit: long, high >= entry price * (1 + take-profit parameter) OR low <= entry price * (1 - stop-loss parameter)
Exit: short, low <= entry price * (1 - take-profit parameter) OR high >= entry price * (1 + stop-loss parameter)