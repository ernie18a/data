Calculation: Opening range high = highest high of bars in the configured opening session, fixed after that session ends
Calculation: Opening range low = lowest low of bars in the configured opening session, fixed after that session ends
Calculation: Long stop = opposite range low or entry close minus opening range size, according to stop mode
Calculation: Long target = entry close plus the distance from entry close to long stop multiplied by the configured risk/reward ratio
Calculation: Short stop = opposite range high or entry close plus opening range size, according to stop mode
Calculation: Short target = entry close minus the distance from entry close to short stop multiplied by the configured risk/reward ratio
Long: opening session has ended AND close > opening range high
Short: opening session has ended AND close < opening range low
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target