Long: no open position AND long entries enabled AND shorter entry MA crosses above longer entry MA AND (slow MA confirmation disabled OR close > slow MA) AND (MACD confirmation disabled OR (MACD line crosses above MACD signal line AND (zero-line filter is either OR (zero-line filter is above AND MACD line > 0) OR (zero-line filter is below AND MACD line < 0))))
Short: no open position AND short entries enabled AND shorter entry MA crosses below longer entry MA AND (slow MA confirmation disabled OR close < slow MA) AND (MACD confirmation disabled OR (MACD line crosses below MACD signal line AND (zero-line filter is either OR (zero-line filter is above AND MACD line > 0) OR (zero-line filter is below AND MACD line < 0))))
Long: first MA of any displayed MA pair >= second MA of that pair
Short: first MA of any displayed MA pair < second MA of that pair
Exit: long, MA cross exit enabled AND shorter exit MA crosses below longer exit MA
Exit: short, MA cross exit enabled AND shorter exit MA crosses above longer exit MA
Exit: long, maximum-bars exit enabled AND bars since long entry signal >= maximum bars
Exit: short, maximum-bars exit enabled AND bars since short entry signal >= maximum bars
Exit: long, low <= entry price - ATR at entry signal * stop-loss multiplier OR high >= entry price + ATR at entry signal * take-profit multiplier
Exit: short, high >= entry price + ATR at entry signal * stop-loss multiplier OR low <= entry price - ATR at entry signal * take-profit multiplier