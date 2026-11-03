Calculation: Previous completed higher-timeframe high = high of the last completed higher-timeframe bar
Calculation: Previous completed higher-timeframe low = low of the last completed higher-timeframe bar
Long: low < Previous completed higher-timeframe low AND close > Previous completed higher-timeframe low AND close > VWAP AND close > EMA AND within the configured session AND no trade has already been taken today
Short: high > Previous completed higher-timeframe high AND close < Previous completed higher-timeframe high AND close < VWAP AND close < EMA AND within the configured session AND no trade has already been taken today
Exit: Long, low <= entry price - stop ATR multiple × ATR OR high >= entry price + take-profit ATR multiple × ATR
Exit: Short, high >= entry price + stop ATR multiple × ATR OR low <= entry price - take-profit ATR multiple × ATR