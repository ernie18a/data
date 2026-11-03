Calculation: EMA score = 3 if close > EMA(close), otherwise −3
Calculation: MACD score = 3 if MACD line > signal line, otherwise −3
Calculation: Open-close EMA score = 3 if EMA(close) − EMA(open) > 0, otherwise −3
Calculation: RSI score = 2 if RSI < 20; 1 if 50 < RSI < 80; −2 if RSI > 80; −1 if 20 < RSI < 50; otherwise 0
Calculation: Stochastic score = 2 if smoothed Stochastic %K < 20; −2 if smoothed Stochastic %K > 80; otherwise 0
Calculation: Bollinger score = 2 if close < lower band; −2 if close > upper band; otherwise 0
Calculation: Trigger = EMA score + MACD score + Open-close EMA score + RSI score + Stochastic score + Bollinger score
Long: Trigger ≥ entry threshold AND datetime > start date AND datetime < end date
Short: Trigger ≤ −entry threshold AND datetime > start date AND datetime < end date
Exit: Long, Trigger < exit threshold
Exit: Short, Trigger > −exit threshold