Calculation: fast MA = selected fast MA type(fast source sampled from T1, shorter lookback), calculated on chart bars using the current forming T1 bar when repainting is enabled and the last completed T1 bar otherwise
Calculation: slow MA = selected slow MA type(slow source sampled from T1, longer lookback), calculated on chart bars using the current forming T1 bar when repainting is enabled and the last completed T1 bar otherwise
Long: fast MA crosses above slow MA
Short: fast MA crosses below slow MA
Long: fast MA crosses above slow MA AND RSI(close, RSI lookback) > minimum RSI threshold AND datetime >= start-date threshold AND position side is flat or short
Exit: long, RSI(exit source, RSI lookback) > maximum RSI threshold
Exit: long, low <= low of long-entry bar * (1 - stop percentage / 100)