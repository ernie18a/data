Calculation: Smoothed RSI = SMA(RSI(close), RSI smoothing length).
Calculation: Histogram expansion = absolute MACD histogram > its previous value AND its previous value > its value two bars ago.
Calculation: Momentum score = EMA of bullish votes minus bearish votes. Bullish votes: 20 if smoothed RSI rises on each of the last two bars AND is above 50; 30 if MACD histogram is positive AND histogram expansion holds, otherwise 15 if MACD line crosses above its signal line; 25 if ADX exceeds its threshold AND rises on each of the last two bars AND +DI > -DI; 15 if close ROC rises on each of the last two bars AND is positive. Bearish votes: 20 if smoothed RSI does not rise on each of the last two bars AND is below 50; 30 if MACD histogram is negative AND histogram expansion holds; 25 if ADX exceeds its threshold AND rises on each of the last two bars AND +DI <= -DI; 15 if close ROC does not rise on each of the last two bars AND is negative. If volume exceeds a multiple of its SMA, add 10 votes to the side with more votes; on a tie add none. Use the same length for ADX and DI smoothing, and a shorter MACD length than the longer MACD length.
Calculation: Confirmed momentum pivot = the momentum score at a bar that is at least as extreme as all scores in the specified left lookback and strictly more extreme than all scores in the specified right lookback; confirm it after the right lookback has elapsed. Compare each confirmed pivot with the immediately preceding confirmed pivot of the same type.
Long: Momentum score >= building threshold AND previous momentum score < building threshold.
Short: Momentum score <= fading threshold AND previous momentum score > fading threshold.
Long: A confirmed momentum pivot low is higher than the preceding pivot low AND the price low at that pivot is lower than at the preceding pivot low AND the distance between pivots is within the inclusive minimum and maximum range.
Short: A confirmed momentum pivot high is lower than the preceding pivot high AND the price high at that pivot is higher than at the preceding pivot high AND the distance between pivots is within the inclusive minimum and maximum range.
Long: Momentum score >= 0.
Short: Momentum score < 0 OR momentum score = 0 AND momentum score < building threshold.
Long: Smoothed RSI rises on each of the last two bars.
Short: Smoothed RSI does not rise on each of the last two bars.
Long: MACD histogram > 0.
Short: MACD histogram <= 0.
Long: Close ROC > 0.
Short: Close ROC <= 0.
Long: +DI > -DI.
Short: +DI <= -DI.