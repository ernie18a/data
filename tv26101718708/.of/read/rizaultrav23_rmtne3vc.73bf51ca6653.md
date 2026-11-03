Calculation: Higher-timeframe values = on historical bars, the final value of the higher-timeframe bar is available from its first chart bar; on the current real-time bar, use the still-forming higher-timeframe bar.
Calculation: WaveTrend = EMA of ((typical price - EMA of typical price) / (0.015 × EMA of the absolute difference between typical price and its EMA)); the two inner EMAs use the same channel length, and the outer EMA uses a separate average length. Use higher-timeframe values.
Calculation: Long stop = entry price × (1 - initial stop percentage) until a bar's high exceeds entry price × (1 + activation percentage); from that bar onward, the stop is the maximum of its preceding value and the current high × (1 - trailing percentage). Initialize at the fixed stop on entry.
Calculation: Short stop = entry price × (1 + initial stop percentage) until a bar's low falls below entry price × (1 - activation percentage); from that bar onward, the stop is the minimum of its preceding value and the current low × (1 + trailing percentage). Initialize at the fixed stop on entry.
Long: For either higher timeframe, its shorter-period close SMA > its longer-period close SMA.
Short: For either higher timeframe, its shorter-period close SMA <= its longer-period close SMA.
Long: Higher-timeframe WaveTrend > 0.
Short: Higher-timeframe WaveTrend <= 0.
Long: Both higher-timeframe shorter-period close SMAs > their respective longer-period close SMAs AND at least one of those comparisons was false on the previous chart bar AND (WaveTrend confirmation is disabled OR higher-timeframe WaveTrend > 0).
Short: Both higher-timeframe shorter-period close SMAs < their respective longer-period close SMAs AND at least one of those comparisons was false on the previous chart bar AND (WaveTrend confirmation is disabled OR higher-timeframe WaveTrend < 0).
Exit: long, current low < previous chart bar's long stop OR the filtered short signal occurs.
Exit: short, current high > previous chart bar's short stop OR the filtered long signal occurs.