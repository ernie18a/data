Calculation: ATR = Average True Range on chart-timeframe bars
Calculation: Supertrend direction = ATR-based Supertrend on hl2 (up or down); the same ATR length and multiplier apply to both uses below
Calculation: DailyTrend = Supertrend direction computed on daily bars (higher timeframe than chart), taken from the daily bar containing the current bar (still forming)
Calculation: ChartTrend = Supertrend direction computed on chart-timeframe bars
Calculation: entryATR = ATR value at the entry bar, held fixed while the position is open
Calculation: Stage3 = both partial-profit targets below have been hit since entry
Calculation: ChandRef = highest close since Stage3 began, including the current bar
Calculation: ATRpeak = highest ATR over a short recent window of bars (shorter than the ATR length used for the trend)
Long: flat AND DailyTrend is up AND close > Hull MA of close AND ADX (Wilder) > threshold AND ADX > previous bar ADX AND Hull MA > previous bar Hull MA AND (high - previous high) > f * ATR (f is a fraction below 1) AND (no prior full exit OR bars since last full exit >= cooldown); enter at the close of the signal bar
Exit: long, low < entryPrice - s * entryATR (full exit)
Exit: long, high >= entryPrice + k1 * entryATR, first time only (partial reduction)
Exit: long, high >= entryPrice + k2 * entryATR, first time only (partial reduction; k2 > k1)
Exit: long, Stage3 AND low <= ChandRef - m * ATRpeak (full exit)
Exit: long, Stage3 AND ChartTrend changes from up on the previous bar to down on the current bar (full exit)