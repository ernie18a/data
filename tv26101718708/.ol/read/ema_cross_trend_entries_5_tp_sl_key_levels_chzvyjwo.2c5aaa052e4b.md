Calculation: Smoothed fast EMA = EMA of the fast EMA
Calculation: Smoothed slow EMA = EMA of the slow EMA
Calculation: Initial long stop = low of the configured prior bar minus buffer; initial short stop = high of the configured prior bar plus buffer
Calculation: Long stop = initial stop, raised to entry plus offset when the configured favorable move is reached; if trailing is enabled, raise it to entry plus offset at TP1 and to the previous TP level at each later TP
Calculation: Short stop = initial stop, lowered to entry minus offset when the configured favorable move is reached; if trailing is enabled, lower it to entry minus offset at TP1 and to the previous TP level at each later TP
Calculation: Long TP levels = entry plus each configured fixed TP distance; short TP levels = entry minus each configured fixed TP distance
Long: fast EMA > slow EMA AND close > fast EMA AND close > slow EMA AND close > smoothed fast EMA AND close > smoothed slow EMA AND fast EMA crossed above slow EMA within the configured entry window, with no active position and no prior signal from that crossover
Short: fast EMA < slow EMA AND close < fast EMA AND close < slow EMA AND close < smoothed fast EMA AND close < smoothed slow EMA AND fast EMA crossed below slow EMA within the configured entry window, with no active position and no prior signal from that crossover
Exit: Long, low <= long stop OR high >= final configured TP level OR (early exit enabled AND close is below the selected exit EMA threshold: fast EMA, both fast and slow EMAs, or all four EMAs)
Exit: Short, high >= short stop OR low <= final configured TP level OR (early exit enabled AND close is above the selected exit EMA threshold: fast EMA, both fast and slow EMAs, or all four EMAs)