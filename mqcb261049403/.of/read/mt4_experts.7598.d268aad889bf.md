Calculation: Active trailing reference = the most favorable price reached since entry, provided the favorable move from entry has reached the trailing activation distance; otherwise undefined.
Long: No open position AND current year >= start year AND current month >= start month AND current year <= end year AND current month <= end month AND ((reversal disabled AND current MACD main line > previous MACD main line) OR (reversal enabled AND current MACD main line < previous MACD main line)).
Short: No open position AND current year >= start year AND current month >= start month AND current year <= end year AND current month <= end month AND ((reversal disabled AND current MACD main line < previous MACD main line) OR (reversal enabled AND current MACD main line > previous MACD main line)).
Long: Position side = long AND current price <= latest entry price - entry spacing.
Short: Position side = short AND current price >= latest entry price + entry spacing.
Exit: long, take profit enabled AND current price >= entry price + take-profit distance AND active trailing reference is undefined.
Exit: short, take profit enabled AND current price <= entry price - take-profit distance AND active trailing reference is undefined.
Exit: long, stop loss enabled AND current price <= entry price - stop-loss distance AND active trailing reference is undefined.
Exit: short, stop loss enabled AND current price >= entry price + stop-loss distance AND active trailing reference is undefined.
Exit: long, trailing stop enabled AND active trailing reference is defined AND (current price <= active trailing reference - trailing distance OR current price >= active trailing reference + take-profit distance + trailing distance).
Exit: short, trailing stop enabled AND active trailing reference is defined AND (current price >= active trailing reference + trailing distance OR current price <= active trailing reference - take-profit distance - trailing distance).