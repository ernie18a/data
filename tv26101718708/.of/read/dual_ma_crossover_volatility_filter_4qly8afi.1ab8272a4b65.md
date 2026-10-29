Long: Fast moving average crosses above the slower moving average AND ATR over a shorter lookback > ATR over a longer lookback AND RSI > long threshold AND bars since the date changed >= bars to skip AND position is flat
Short: Fast moving average crosses below the slower moving average AND ATR over a shorter lookback > ATR over a longer lookback AND RSI < short threshold AND bars since the date changed >= bars to skip AND position is flat
Calculation: Initial long stop = entry price − ATR × stop multiple, set at entry
Calculation: Initial short stop = entry price + ATR × stop multiple, set at entry
Calculation: Long breakeven trigger = maximum high since entry − entry price >= breakeven multiple × current ATR × stop multiple; when reached, set stop to entry price
Calculation: Short breakeven trigger = entry price − minimum low since entry >= breakeven multiple × current ATR × stop multiple; when reached, set stop to entry price
Calculation: After breakeven, long trailing stop = maximum of prior stop and maximum high since entry − current ATR × trail multiple
Calculation: After breakeven, short trailing stop = minimum of prior stop and minimum low since entry + current ATR × trail multiple
Exit: Long, low <= current stop OR bars since entry >= time-stop lookback AND highest high over that lookback <= highest high over the prior lookback
Exit: Short, high >= current stop OR bars since entry >= time-stop lookback AND lowest low over that lookback >= lowest low over the prior lookback