Calculation: LongRisk = entry price - (low at entry bar - stop multiple * ATR(atr length) at entry bar)
Calculation: ShortRisk = (high at entry bar + stop multiple * ATR(atr length) at entry bar) - entry price
Long: trigger mode enables long AND signal source crosses above SMA(signal source, signal SMA length)
Short: trigger mode enables short AND signal source crosses below SMA(signal source, signal SMA length)
Exit: long, bar after entry bar AND high >= entry price + TP3 multiple * LongRisk
Exit: long, low <= entry price - LongRisk
Exit: long, breakeven enabled AND highest high over bars after entry bar through current bar >= entry price + TP1 multiple * LongRisk AND low <= entry price
Exit: short, bar after entry bar AND low <= entry price - TP3 multiple * ShortRisk
Exit: short, high >= entry price + ShortRisk
Exit: short, breakeven enabled AND lowest low over bars after entry bar through current bar <= entry price - TP1 multiple * ShortRisk AND high >= entry price