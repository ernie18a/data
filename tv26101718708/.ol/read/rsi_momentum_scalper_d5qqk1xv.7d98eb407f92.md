Calculation: RSI momentum = current-bar RSI minus prior-bar RSI
Calculation: High volume = current-bar volume > volume moving average × volume multiplier
Calculation: Long take-profit level = entry price × (1 + take-profit percentage)
Calculation: Long fixed stop = entry price × (1 − stop-loss percentage)
Calculation: Long trailing stop = highest high since entry, including entry price, × (1 − trailing-stop percentage)
Calculation: Effective long stop = max(long fixed stop, long trailing stop)
Calculation: Short take-profit level = entry price × (1 − take-profit percentage)
Calculation: Short fixed stop = entry price × (1 + stop-loss percentage)
Calculation: Short trailing stop = lowest low since entry, including entry price, × (1 + trailing-stop percentage)
Calculation: Effective short stop = min(short fixed stop, short trailing stop)
Long: (RSI momentum > momentum threshold OR (RSI < oversold threshold AND RSI > prior-bar RSI) OR RSI crosses above oversold threshold) AND high volume AND close > prior-bar close AND trade mode is Both or Long Only
Short: (RSI momentum < −momentum threshold OR (RSI > overbought threshold AND RSI < prior-bar RSI) OR RSI crosses below overbought threshold) AND high volume AND close < prior-bar close AND trade mode is Both or Short Only
Exit: Long, high >= long take-profit level OR low <= effective long stop
Exit: Short, low <= short take-profit level OR high >= effective short stop