Calculation: Dow Theory trend = initially neutral; switch to up when close > latest swing high and to down when close < latest swing low, otherwise retain the current direction; latest swing high is the most recent high[swing lookback] equal to highest(high, 2 × swing lookback + 1), and latest swing low is the most recent low[swing lookback] equal to lowest(low, 2 × swing lookback + 1)
Calculation: ATR target distance(target multiple) = ATR(ATR lookback) sampled on the entry bar × ATR multiplier × target multiple; first-target multiple < second-target multiple < third-target multiple
Long: EMA(close, EMA lookback) > EMA(close, EMA lookback)[1] AND Dow Theory trend is up AND ADX(DI lookback, ADX smoothing) > ADX threshold
Short: EMA(close, EMA lookback) < EMA(close, EMA lookback)[1] AND Dow Theory trend is down AND ADX(DI lookback, ADX smoothing) > ADX threshold
Exit: long, (close − entry price) / entry price × 100 < stop-loss threshold
Exit: short, (entry price − close) / entry price × 100 < stop-loss threshold
Exit: long, Dow Theory trend is down
Exit: short, Dow Theory trend is up
Exit: long, high > entry price + ATR target distance(first-target multiple) AND this target has not been hit earlier in the current position
Exit: long, high > entry price + ATR target distance(second-target multiple) AND this target has not been hit earlier in the current position
Exit: long, high > entry price + ATR target distance(third-target multiple) AND this target has not been hit earlier in the current position
Exit: short, low < entry price − ATR target distance(first-target multiple) AND this target has not been hit earlier in the current position
Exit: short, low < entry price − ATR target distance(second-target multiple) AND this target has not been hit earlier in the current position
Exit: short, low < entry price − ATR target distance(third-target multiple) AND this target has not been hit earlier in the current position