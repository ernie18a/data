Calculation: Trend factor = +1 when the fast EMA is above the slow EMA, −1 when below, otherwise 0; the fast EMA uses a shorter length than the slow EMA.
Calculation: Momentum factor = +1 when RSI > 50, otherwise −1 when RSI < 50, otherwise 0.
Calculation: MACD factor = +1 when the MACD histogram is positive, −1 when negative, otherwise 0.
Calculation: Strength factor = 0 when ADX is below its threshold; otherwise +1 when +DI > −DI, −1 when −DI > +DI, otherwise 0.
Calculation: Volume factor = +1 when volume is at least 1.2 times its moving average and close > open; −1 when volume is at least 1.2 times its moving average and close < open; otherwise 0.
Calculation: Location factor = +1 when close is in the bottom 35% of the recent high-low range; −1 when in the top 35%; otherwise 0.
Calculation: Confluence score = 100 × weighted sum of the six factors divided by the sum of their weights; smooth the score with a short EMA.
Calculation: Bull votes = count of factors > 0; bear votes = count of factors < 0.
Calculation: Risk distance = ATR at entry × stop multiple, or ATR at entry if that product is not positive; TP1 distance = risk distance × first-target R multiple.
Long: smoothed confluence score ≥ threshold AND bull votes ≥ minimum agreeing factors AND signal state ≤ 0.
Short: smoothed confluence score ≤ −threshold AND bear votes ≥ minimum agreeing factors AND signal state ≥ 0.
Exit: long, low ≤ entry price − risk distance OR high ≥ entry price + TP1 distance OR short signal.
Exit: short, high ≥ entry price + risk distance OR low ≤ entry price − TP1 distance OR long signal.