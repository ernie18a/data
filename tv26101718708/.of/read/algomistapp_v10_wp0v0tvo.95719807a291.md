Long: Fast Hull moving average crosses above slow Hull moving average (current fast > current slow AND previous fast <= previous slow) AND chart-timeframe ATR > its minimum threshold AND higher-timeframe ATR of the still-forming bar > its minimum threshold AND position is flat
Short: Slow Hull moving average crosses above fast Hull moving average (current slow > current fast AND previous slow <= previous fast) AND chart-timeframe ATR > its minimum threshold AND higher-timeframe ATR of the still-forming bar > its minimum threshold AND position is flat
Calculation: Long stop = signal-bar midpoint (high + low) / 2 minus chart-timeframe ATR × stop-distance parameter
Calculation: Long target = signal-bar midpoint (high + low) / 2 plus chart-timeframe ATR × target-distance parameter
Calculation: Short stop = signal-bar midpoint (high + low) / 2 plus chart-timeframe ATR × stop-distance parameter
Calculation: Short target = signal-bar midpoint (high + low) / 2 minus chart-timeframe ATR × target-distance parameter
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target