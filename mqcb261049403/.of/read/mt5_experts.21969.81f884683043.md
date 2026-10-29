Calculation: Fast moving average = moving average with a shorter lookback, calculated from close prices on the configured signal timeframe; evaluate the last completed bar and its preceding bar.
Calculation: Slow moving average = moving average with a longer lookback than the fast moving average, calculated from close prices on the configured signal timeframe; evaluate the last completed bar and its preceding bar.
Long: Fast moving average on the last completed signal-timeframe bar > slow moving average AND fast moving average on the preceding signal-timeframe bar < slow moving average
Short: Fast moving average on the last completed signal-timeframe bar < slow moving average AND fast moving average on the preceding signal-timeframe bar > slow moving average
Exit: long, short condition
Exit: short, long condition