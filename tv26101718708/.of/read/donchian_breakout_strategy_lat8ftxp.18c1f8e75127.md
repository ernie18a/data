Calculation: Entry Donchian high = highest high over the longer lookback, excluding the current bar
Calculation: Entry Donchian low = lowest low over the longer lookback, excluding the current bar
Calculation: Exit Donchian low = lowest low over the shorter lookback, excluding the current bar
Calculation: Exit Donchian high = highest high over the shorter lookback, excluding the current bar
Calculation: Long stop = close minus ATR multiplied by the stop multiplier, set when the long-entry condition is true
Calculation: Short stop = close plus ATR multiplied by the stop multiplier, set when the short-entry condition is true
Long: close > Entry Donchian high AND close > EMA(close) AND RSI(close) > 50 AND ATR > SMA(ATR) AND volume > SMA(volume)
Short: close < Entry Donchian low AND close < EMA(close) AND RSI(close) < 50 AND ATR > SMA(ATR) AND volume > SMA(volume)
Exit: Long, close < Exit Donchian low OR low <= Long stop
Exit: Short, close > Exit Donchian high OR high >= Short stop