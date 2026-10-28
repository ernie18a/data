Long: EMA(7) crosses above EMA(144) OR EMA(14) crosses above EMA(144), AND EMA(7) > EMA(14) > EMA(21), AND +DI(14) > -DI(14), AND ADX(14) > threshold, AND not already in a long position, AND datetime is within the configured backtest date range
Short: EMA(7) crosses below EMA(144) OR EMA(14) crosses below EMA(144), AND EMA(7) < EMA(14) < EMA(21), AND -DI(14) > +DI(14), AND ADX(14) > threshold, AND not already in a short position, AND datetime is within the configured backtest date range
Exit: Long, high >= entry price + ATR(20) × stop-loss multiplier
Exit: Long, high >= entry price + 2 × ATR(20) × stop-loss multiplier
Exit: Long, high >= entry price + 3 × ATR(20) × stop-loss multiplier
Exit: Long, low <= current stop price
Exit: Long, datetime is outside the configured backtest date range
Exit: Short, low <= entry price - ATR(20) × stop-loss multiplier
Exit: Short, low <= entry price - 2 × ATR(20) × stop-loss multiplier
Exit: Short, low <= entry price - 3 × ATR(20) × stop-loss multiplier
Exit: Short, high >= current stop price
Exit: Short, datetime is outside the configured backtest date range