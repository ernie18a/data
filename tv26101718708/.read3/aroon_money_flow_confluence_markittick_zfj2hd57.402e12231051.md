Calculation: filtered Aroon = selected smoothing method(Aroon Oscillator(Aroon lookback), smoothing lookback), or raw Aroon Oscillator when smoothing is off
Calculation: filtered CMF = the same selected smoothing method(CMF(CMF lookback), smoothing lookback), or raw CMF when smoothing is off
Calculation: confirmation window = when auto mode is enabled, use the rounded median of the latest sample-capacity gaps after at least the minimum sample count, clamped to the minimum and maximum window; each sample is the chart-bar gap from an Aroon zero cross to the first same-direction agreement within the maximum confirmation gap, recorded on closed bars; before enough samples exist, use round((CMF lookback − 1) / initial-window divisor); otherwise use the manual confirmation-bars parameter
Calculation: stop distance = ATR(ATR lookback) × stop multiplier
Calculation: target multiples = the TP1, TP2, and TP3 R parameters sorted from smallest to largest
Calculation: entry price = close of signal bar; long stop = entry price − stop distance; long targets = entry price + stop distance × each target multiple; short stop = entry price + stop distance; short targets = entry price − stop distance × each target multiple
Long: filtered Aroon >= 0
Short: filtered Aroon < 0
Long: filtered CMF >= 0
Short: filtered CMF < 0
Long: filtered Aroon > 0 AND filtered CMF > flow buffer
Short: filtered Aroon < 0 AND filtered CMF < −flow buffer
Long: Aroon Oscillator(Aroon lookback, T1, last completed bar) > 0 when higher-timeframe confirmation is enabled and T1 is at least the chart timeframe
Short: Aroon Oscillator(Aroon lookback, T1, last completed bar) < 0 when higher-timeframe confirmation is enabled and T1 is at least the chart timeframe
Long: filtered Aroon > 0 AND filtered CMF > flow buffer AND this agreement is newly true on the chart bar AND bars since the latest upward zero cross of filtered Aroon <= confirmation window AND (trend-strength filter disabled OR ADX(ADX lookback)[1] >= minimum ADX) AND (higher-timeframe confirmation disabled OR T1 is below the chart timeframe OR Aroon Oscillator(Aroon lookback, T1, last completed bar) > 0) AND the chart bar is closed AND NOT(signal lock enabled AND this is the latest chart bar) AND stop distance > minimum tick size AND entry price − stop distance > 0
Short: filtered Aroon < 0 AND filtered CMF < −flow buffer AND this agreement is newly true on the chart bar AND bars since the latest downward zero cross of filtered Aroon <= confirmation window AND (trend-strength filter disabled OR ADX(ADX lookback)[1] >= minimum ADX) AND (higher-timeframe confirmation disabled OR T1 is below the chart timeframe OR Aroon Oscillator(Aroon lookback, T1, last completed bar) < 0) AND the chart bar is closed AND NOT(signal lock enabled AND this is the latest chart bar) AND stop distance > minimum tick size AND entry price − stop distance × largest target multiple > 0
Exit: long, on a closed chart bar after entry, close < long stop
Exit: short, on a closed chart bar after entry, close > short stop
Exit: long, on a chart bar after entry, high >= first long target for the first time
Exit: long, on a chart bar after entry, high >= second long target for the first time
Exit: short, on a chart bar after entry, low <= first short target for the first time
Exit: short, on a chart bar after entry, low <= second short target for the first time
Exit: long, on a chart bar after entry, high >= third long target
Exit: short, on a chart bar after entry, low <= third short target
Exit: long, a new long entry signal while a long position is open
Exit: short, a new short entry signal while a short position is open