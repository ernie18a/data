Calculation: Heikin-Ashi close = (open + high + low + close) / 4
Calculation: Rate of change of a series = 100 × (current value − value [lookback bars ago]) / value [lookback bars ago]
Calculation: Selected source = close, volume, rate of change of close, Heikin-Ashi close, volume, or rate of change of Heikin-Ashi close
Calculation: EMA = exponential moving average of the selected source
Calculation: Volume average = simple moving average of volume
Long: Selected source crosses above its EMA AND ADX ≥ threshold AND volume > volume average × multiplier
Short: Selected source crosses below its EMA AND ADX ≥ threshold AND volume > volume average × multiplier
Exit: Long, reverse-signal mode AND short condition OR ATR mode AND (low ≤ entry price − ATR × stop multiplier OR high ≥ entry price + ATR × target multiplier) OR percent mode AND (low ≤ entry price × (1 − stop percentage) OR high ≥ entry price × (1 + target percentage))
Exit: Short, reverse-signal mode AND long condition OR ATR mode AND (high ≥ entry price + ATR × stop multiplier OR low ≤ entry price − ATR × target multiplier) OR percent mode AND (high ≥ entry price × (1 + stop percentage) OR low ≤ entry price × (1 − target percentage))