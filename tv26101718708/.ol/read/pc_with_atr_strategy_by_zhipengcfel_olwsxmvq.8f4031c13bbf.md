Calculation: Higher-timeframe ATR = ATR of the higher-timeframe bar still forming
Calculation: Previous higher-timeframe close = close of the last completed higher-timeframe bar
Calculation: Previous higher-timeframe low = low of the last completed higher-timeframe bar
Calculation: Previous higher-timeframe high = high of the last completed higher-timeframe bar
Calculation: Long entry level = previous higher-timeframe close + buy-entry ATR multiple × higher-timeframe ATR
Calculation: Long target = previous higher-timeframe low + buy-exit ATR multiple × higher-timeframe ATR
Calculation: Long stop = previous higher-timeframe close + long-stop ATR multiple × higher-timeframe ATR
Calculation: Short entry level = previous higher-timeframe close − sell-entry ATR multiple × higher-timeframe ATR
Calculation: Short target = previous higher-timeframe high − sell-exit ATR multiple × higher-timeframe ATR
Calculation: Short stop = previous higher-timeframe close − short-stop ATR multiple × higher-timeframe ATR
Long: close > long entry level AND close < long target AND bar year > configured backtest start year
Short: close < short entry level AND close > short target AND bar year > configured backtest start year
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target