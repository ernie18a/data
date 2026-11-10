Long: Chart close > EMA of close on the weekly timeframe.
Short: Chart close < EMA of close on the weekly timeframe.
Long: Daily close > EMA of daily close.
Short: Daily close < EMA of daily close.
Long: Chart close > weekly EMA AND daily close > daily EMA.
Short: Chart close < weekly EMA AND daily close < daily EMA.
Long: Chart close > weekly EMA AND daily close > daily EMA AND ADX > threshold AND chart low <= chart EMA AND chart close > chart EMA.
Short: Chart close < weekly EMA AND daily close < daily EMA AND ADX > threshold AND chart high >= chart EMA AND chart close < chart EMA.
Exit: long, low <= entry price - ATR at setup bar * stop multiplier OR high >= entry price + ATR at setup bar * stop multiplier * second target multiplier.
Exit: short, high >= entry price + ATR at setup bar * stop multiplier OR low <= entry price - ATR at setup bar * stop multiplier * second target multiplier.
Calculation: Weekly and daily values = on a higher timeframe, use the last completed bar in historical evaluation and the still-forming bar in real time; on a lower timeframe, use the last available lower-timeframe bar within the chart bar; on the chart timeframe, use the current bar.