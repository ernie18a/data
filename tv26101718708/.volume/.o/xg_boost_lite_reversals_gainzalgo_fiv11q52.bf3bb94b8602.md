Calculation: Long classifier probability = gradient-boosted classifier score from RSI, relative volume (volume / its moving average), close z-score ((close − moving average) / standard deviation), and ADX; train on prior completed bars labeled positive when the following outcome window’s highest high exceeds the entry close by more than 1 ATR.
Calculation: Short classifier probability = same features and training method, labeled positive when the entry close exceeds the following outcome window’s lowest low by more than 1 ATR.
Calculation: Bullish pivot = low < lowest low of the preceding lookback bars AND close > (low + high) / 2.
Calculation: Bearish pivot = high > highest high of the preceding lookback bars AND close < (low + high) / 2.
Calculation: Initial long stop = signal-bar low − ATR × wick buffer, adjusted so entry-to-stop distance is at least 0.5 ATR.
Calculation: Initial short stop = signal-bar high + ATR × wick buffer, adjusted so stop-to-entry distance is at least 0.5 ATR.
Calculation: TP1 = entry price ± initial risk distance × target risk multiple (add for long, subtract for short).
Long: bullish pivot AND long classifier probability ≥ signal threshold AND ADX ≥ minimum filter; signal bar is confirmed closed.
Short: bearish pivot AND short classifier probability ≥ signal threshold AND ADX ≥ minimum filter; signal bar is confirmed closed.
Exit: long, low ≤ current stop; after high ≥ TP1, current stop moves to entry.
Exit: short, high ≥ current stop; after low ≤ TP1, current stop moves to entry.