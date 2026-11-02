Long: close < close at the arrival lookback
Short: close > close at the arrival lookback
Exit: long, close >= exit EMA AND previous close < previous exit EMA
Exit: short, close <= exit EMA AND previous close > previous exit EMA
Exit: long, high >= entry price + current ATR × target multiplier
Exit: short, low <= entry price - current ATR × target multiplier
Exit: long, close - entry price >= current ATR × protection multiplier AND this protection condition has not previously been reached during the position
Exit: short, entry price - close >= current ATR × protection multiplier AND this protection condition has not previously been reached during the position
Exit: long, high >= entry price + ATR at entry × target multiplier
Exit: short, low <= entry price - ATR at entry × target multiplier