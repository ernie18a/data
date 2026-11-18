Calculation: Start timestamp = timestamp(start year, start month, start day, start hour, start minute)
Calculation: End timestamp = timestamp(end year, end month, end day, end hour, end minute)
Calculation: Crossing close = ValueWhen(close crosses either direction through selected moving average(close, moving-average lookback, moving-average type), close, most recent chart-bar occurrence)
Calculation: Crossing range = ValueWhen(close crosses either direction through selected moving average(close, moving-average lookback, moving-average type), ATR multiplier × ATR(ATR lookback, T1, still-forming bar calculated on T1 bars and mapped to chart bars), most recent chart-bar occurrence)
Long: close crosses above selected moving average(close, moving-average lookback, moving-average type) AND datetime >= Start timestamp AND datetime <= End timestamp
Short: close crosses below selected moving average(close, moving-average lookback, moving-average type) AND datetime >= Start timestamp AND datetime <= End timestamp
Exit: Long, low <= Crossing close - Crossing range OR high >= Crossing close + Crossing range
Exit: Long, position size = long-size parameter AND low <= the prior chart bar's Crossing close
Exit: Short, low <= Crossing close - Crossing range OR high >= Crossing close + Crossing range
Exit: Short, position size = short-size parameter AND high >= the prior chart bar's Crossing close