Calculation: Higher-timeframe trend vote = On each of six higher timeframes, using its last completed bar, add +1 if the faster EMA is above the slower EMA, -1 if below, and 0 if equal; also add +1 if close is above the faster EMA, -1 if below, and 0 if equal; the vote is +1 if the sum is positive, -1 if negative, and 0 if zero.
Calculation: Chart EMA-stack vote = +1 if the short EMA is above the medium EMA and the medium EMA is above the long EMA; -1 if the short EMA is below the medium EMA and the medium EMA is below the long EMA; otherwise +1 if the short EMA is above the long EMA, else -1. The short, medium, and long EMA lookbacks are progressively longer.
Calculation: Chart Supertrend vote = +1 when Supertrend indicates an uptrend, otherwise -1.
Calculation: Chart RSI vote = +1 when RSI is at least 50, otherwise -1.
Calculation: Chart MACD histogram vote = +1 when the MACD histogram is at least zero, otherwise -1.
Calculation: Smoothed alignment score = a short EMA of 10 times the sum of the six higher-timeframe trend votes and four chart votes, divided by 10.
Calculation: Initial stop and first target = At entry, risk is ATR times a stop multiple; for a long, stop is entry price minus risk and first target is entry price plus risk times a target multiple; for a short, stop is entry price plus risk and first target is entry price minus risk times a target multiple.
Calculation: Signal state = starts flat; becomes long after a Long decision and short after a Short decision.
Long: Smoothed alignment score is at least the alignment threshold AND chart MACD histogram is above zero AND chart RSI is above 50 AND signal state is flat or short.
Short: Smoothed alignment score is at most negative the alignment threshold AND chart MACD histogram is below zero AND chart RSI is below 50 AND signal state is flat or long.
Exit: long, high is at or above the first target OR low is at or below the initial stop OR Short condition is true
Exit: short, low is at or below the first target OR high is at or above the initial stop OR Long condition is true