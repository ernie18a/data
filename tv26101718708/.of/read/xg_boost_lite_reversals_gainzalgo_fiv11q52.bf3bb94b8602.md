Calculation: Relative volume = volume / moving average of volume
Calculation: Price z-score = (close − moving average of close) / standard deviation of close
Calculation: Long classifier probability = gradient-boosted classifier output trained on RSI, relative volume, price z-score, and ADX; label is whether the next fixed forward window’s highest high exceeds entry close by more than one ATR
Calculation: Short classifier probability = gradient-boosted classifier output trained on RSI, relative volume, price z-score, and ADX; label is whether entry close exceeds the next fixed forward window’s lowest low by more than one ATR
Calculation: Long initial stop = signal-bar low − ATR-scaled wick buffer, adjusted so entry-to-stop distance is at least a minimum ATR-scaled risk distance
Calculation: Short initial stop = signal-bar high + ATR-scaled wick buffer, adjusted so stop-to-entry distance is at least a minimum ATR-scaled risk distance
Calculation: Long TP1 = entry price + initial risk distance × TP1 risk multiple
Calculation: Short TP1 = entry price − initial risk distance × TP1 risk multiple
Calculation: Long active stop = initial stop until TP1 is reached; then entry price
Calculation: Short active stop = initial stop until TP1 is reached; then entry price
Long: long classifier probability ≥ minimum signal probability AND ADX ≥ minimum ADX filter AND low < lowest prior lows over the pivot lookback AND close > low + (high − low) / 2
Short: short classifier probability ≥ minimum signal probability AND ADX ≥ minimum ADX filter AND high > highest prior highs over the pivot lookback AND close < low + (high − low) / 2
Exit: long, after the entry bar, low ≤ long active stop
Exit: short, after the entry bar, high ≥ short active stop