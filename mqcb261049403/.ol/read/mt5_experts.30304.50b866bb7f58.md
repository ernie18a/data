Calculation: Trigger range = ATR(20) of higher-timeframe daily bars, using the last completed bar, × trigger percentage
Calculation: Remaining range = ATR(20) of higher-timeframe daily bars, using the last completed bar, − trigger range
Long: close − low of the current forming higher-timeframe daily bar > trigger range AND no trade has been opened during the current daily bar
Short: high of the current forming higher-timeframe daily bar − close > trigger range AND no trade has been opened during the current daily bar
Exit: long, close ≤ entry price − trigger range OR close ≥ entry price + remaining range OR datetime reaches the end of the current daily bar
Exit: short, close ≥ entry price + trigger range OR close ≤ entry price − remaining range OR datetime reaches the end of the current daily bar