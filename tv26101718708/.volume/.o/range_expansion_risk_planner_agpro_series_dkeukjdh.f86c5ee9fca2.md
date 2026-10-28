Calculation: Source range high/low = highest high/lowest low over the lookback, excluding the current bar
Calculation: Failure rail = broken source-range edge minus (long) or plus (short) an ATR-scaled buffer
Calculation: Target = the nearer of the measured-range target beyond the broken edge and the nearest older target-side obstacle; use the measured-range target if no such obstacle exists
Long: Close exceeds the source range high by at least an ATR-scaled threshold
Short: Close falls below the source range low by at least an ATR-scaled threshold
Exit: long, close falls below the failure rail OR high reaches the target
Exit: short, close rises above the failure rail OR low reaches the target