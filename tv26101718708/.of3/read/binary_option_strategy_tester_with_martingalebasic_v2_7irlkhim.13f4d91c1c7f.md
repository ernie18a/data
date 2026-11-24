Calculation: X = EMA(close, shortest lookback) - EMA(EMA(close, shortest lookback), shortest lookback) + EMA(EMA(EMA(close, shortest lookback), shortest lookback), shortest lookback)
Calculation: Y = 2 * EMA(close, longer lookback) - EMA(EMA(close, longer lookback), shorter lookback)
Calculation: Z = X > Y ? max(EMA(highest((low + close) / 2, shorter lookback), shorter lookback), EMA(lowest((high + close) / 2, longer lookback), longer lookback)) : min(EMA(highest((low + close) / 2, shorter lookback), shorter lookback), EMA(lowest((high + close) / 2, longer lookback), longer lookback))
Option: buy call, X > Y AND Z > low AND Z - Z[1] > Z[1] - Z[2]
Option: buy put, X < Y AND Z < high AND Z[1] - Z > Z[2] - Z[1]