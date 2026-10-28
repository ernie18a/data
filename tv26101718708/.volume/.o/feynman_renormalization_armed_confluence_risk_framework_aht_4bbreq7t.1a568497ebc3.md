Calculation: Buy score = 3 when close > EMA, plus 3 when volume > volume SMA, plus 2 when RSI < 65, plus 2 when close > open; otherwise each component contributes 0
Calculation: Sell score = 3 when close < EMA, plus 3 when volume > volume SMA, plus 2 when RSI > 35, plus 2 when close < open; otherwise each component contributes 0
Calculation: Long stop-entry price = setup bar high + 1.5 × ATR
Calculation: Short stop-entry price = setup bar low − 1.5 × ATR
Long: Buy score ≥ minimum score AND position size ≤ 0; enter when price reaches the active long stop-entry price
Short: Sell score ≥ minimum score AND position size ≥ 0; enter when price reaches the active short stop-entry price