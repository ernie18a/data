Calculation: EMA trend score = +3 if close is above the EMA, otherwise -3
Calculation: MACD trend score = +3 if the MACD line is above its signal line, otherwise -3
Calculation: open-close EMA score = +3 if the EMA of close minus the EMA of open is positive, otherwise -3; use the same lookback for both EMAs
Calculation: RSI score = +2 if RSI < 20, +1 if 50 < RSI < 80, -2 if RSI > 80, -1 if 20 < RSI < 50, otherwise 0
Calculation: stochastic score = +2 if the smoothed stochastic %K is below 20, -2 if it is above 80, otherwise 0; smooth %K with a simple moving average
Calculation: Bollinger band score = +2 if close is below the lower band, -2 if close is above the upper band, otherwise 0
Calculation: trigger score = EMA trend score + MACD trend score + open-close EMA score + RSI score + stochastic score + Bollinger band score
Long: trigger score >= configured entry threshold AND datetime is within the configured date window
Short: trigger score <= negative configured entry threshold AND datetime is within the configured date window
Exit: long, trigger score < configured exit threshold
Exit: short, trigger score > negative configured exit threshold