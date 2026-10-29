Calculation: ATR buffer = ATR multiplied by a parameter
Calculation: Swing low = lowest low over a lookback
Calculation: Swing high = highest high over a lookback
Calculation: Long stop = swing low at entry minus ATR buffer
Calculation: Short stop = swing high at entry plus ATR buffer
Calculation: Long TP1 and TP2 = entry price plus ATR multiplied by the respective target parameters, with TP2 farther from entry than TP1
Calculation: Short TP1 and TP2 = entry price minus ATR multiplied by the respective target parameters, with TP2 farther from entry than TP1
Long: completed-bar close > VWAP + ATR buffer AND close > open AND close > previous bar high AND RSI > 50
Short: completed-bar close < VWAP - ATR buffer AND close < open AND close < previous bar low AND RSI < 50
Exit: long, low <= long stop OR high >= long TP1 OR high >= long TP2
Exit: short, high >= short stop OR low <= short TP1 OR low <= short TP2