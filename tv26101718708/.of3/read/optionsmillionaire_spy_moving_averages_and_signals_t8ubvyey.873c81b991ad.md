Long: on chart bars, MA(close, shorter lookback, short MA type, T1, last completed bar) > MA(close, longer lookback, long MA type, T1, last completed bar)
Short: on chart bars, MA(close, shorter lookback, short MA type, T1, last completed bar) < MA(close, longer lookback, long MA type, T1, last completed bar)
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + profit-target percentage)
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - profit-target percentage)
Option: buy call, EMA(close, fast period) > EMA(close, slow period)
Option: buy put, EMA(close, fast period) < EMA(close, slow period)
Option: buy call, EMA(close, fast period) crosses above EMA(close, slow period)
Option: buy put, EMA(close, fast period) crosses below EMA(close, slow period)
Option: buy call, close > HMA(close, period)
Option: buy put, close < HMA(close, period)
Calculation: option return = (current option price - entry option price) / entry option price
Exit: long, option return <= -early loss threshold
Exit: long, option return <= -maximum loss threshold
Exit: short, option return <= -early loss threshold
Exit: short, option return <= -maximum loss threshold
Exit: long, option return >= profit target
Exit: short, option return >= profit target
Exit: long, time >= regular session close
Exit: short, time >= regular session close