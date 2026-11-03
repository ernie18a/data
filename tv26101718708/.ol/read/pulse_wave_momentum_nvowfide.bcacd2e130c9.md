Calculation: Smoothed RSI = RSI of close, smoothed by a shorter simple moving average
Calculation: Expanding MACD histogram = absolute MACD histogram exceeds its value on each of the prior two bars
Calculation: Rising ADX = ADX exceeds its value on each of the prior two bars
Calculation: Rising ROC = rate of change of close exceeds its value on each of the prior two bars
Calculation: Momentum score = EMA of length 2 of (bull votes − bear votes). Bull votes: +20 if smoothed RSI is rising and >50; +30 if MACD histogram >0 and expanding, otherwise +15 if MACD line crosses above signal line; +25 if ADX exceeds its threshold, is rising, and +DI > −DI; +15 if ROC is rising and >0. Bear votes: +20 if smoothed RSI is not rising and <50; +30 if MACD histogram <0 and expanding; +25 if ADX exceeds its threshold, is rising, and +DI ≤ −DI; +15 if ROC is not rising and <0. If volume exceeds its longer-term simple moving average times a multiplier, add 10 to bull votes if bull votes initially exceed bear votes; then add 10 to bear votes if bear votes exceed bull votes after that first addition.
Calculation: Regular bullish divergence = At confirmed price/oscillator pivot lows, current low is below the previous pivot low and current smoothed momentum score is above the previous pivot score; the pivot separation is within a minimum and maximum bar range.
Calculation: Regular bearish divergence = At confirmed price/oscillator pivot highs, current high is above the previous pivot high and current smoothed momentum score is below the previous pivot score; the pivot separation is within a minimum and maximum bar range.
Long: Momentum score ≥ building threshold AND prior-bar momentum score < building threshold
Long: Regular bullish divergence
Short: Momentum score ≤ fading threshold AND prior-bar momentum score > fading threshold
Short: Regular bearish divergence