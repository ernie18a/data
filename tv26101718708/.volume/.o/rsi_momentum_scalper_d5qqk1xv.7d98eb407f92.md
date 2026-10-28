Calculation: RSI momentum = current RSI minus previous bar's RSI
Calculation: Long peak = highest high since long entry, initialized to the greater of the entry bar's high and entry price
Calculation: Short trough = lowest low since short entry, initialized to the lesser of the entry bar's low and entry price
Calculation: Long take-profit price = entry price × (1 + take-profit percentage)
Calculation: Long effective stop = greater of entry price × (1 − stop-loss percentage) and long peak × (1 − trailing-stop percentage)
Calculation: Short take-profit price = entry price × (1 − take-profit percentage)
Calculation: Short effective stop = lesser of entry price × (1 + stop-loss percentage) and short trough × (1 + trailing-stop percentage)
Long: position is flat AND trade mode is Both or Long Only AND (RSI momentum > momentum threshold OR (RSI < oversold threshold AND RSI > previous bar's RSI) OR (current RSI > oversold threshold AND previous bar's RSI ≤ oversold threshold)) AND volume > volume SMA × volume multiplier AND close > previous bar's close
Short: position is flat AND trade mode is Both or Short Only AND (RSI momentum < −momentum threshold OR (RSI > overbought threshold AND RSI < previous bar's RSI) OR (current RSI < overbought threshold AND previous bar's RSI ≥ overbought threshold)) AND volume > volume SMA × volume multiplier AND close < previous bar's close
Exit: long, low ≤ long effective stop OR high ≥ long take-profit price
Exit: short, high ≥ short effective stop OR low ≤ short take-profit price