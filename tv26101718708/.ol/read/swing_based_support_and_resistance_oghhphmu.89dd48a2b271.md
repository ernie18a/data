Calculation: Chart-timeframe level = When the current high exceeds each of the prior two highs, set the level to the current low; otherwise, when the current low is below each of the prior two lows, set it to the current high; otherwise, retain the previous level.
Calculation: Higher-timeframe level = Apply the same level calculation to higher-timeframe bars, using the last completed higher-timeframe bar.
Long: Close > chart-timeframe level OR close > higher-timeframe level
Short: Close < chart-timeframe level OR close < higher-timeframe level