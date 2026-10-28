Calculation: Range high and range low = high and low of the completed bar with the lowest volume in the configured range window.
Calculation: Confirmed swing high/low = a bar high/low higher/lower than the corresponding highs/lows of the configured number of bars on both sides; use the latest confirmed swing since the start of the day.
Long: At the configured evaluation time, close > range high AND latest confirmed swing low < close AND no trade has been taken today.
Short: At the configured evaluation time, close < range low AND latest confirmed swing high > close AND no trade has been taken today.
Long: After a long trade is stopped out, position is flat AND latest confirmed swing low < close AND entry price > latest confirmed swing low.
Short: After a short trade is stopped out, position is flat AND latest confirmed swing high > close AND latest confirmed swing high > entry price.
Exit: long, low <= stop at entry OR high >= target at entry.
Exit: short, high >= stop at entry OR low <= target at entry.