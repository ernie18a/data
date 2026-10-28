Calculation: Trend vote = +1 when the shorter-period EMA of close is above the longer-period EMA; −1 when below; otherwise 0
Calculation: RSI vote = +1 when RSI is above 50; −1 when below; otherwise 0
Calculation: MACD vote = +1 when the MACD histogram is above zero; −1 when below; otherwise 0
Calculation: Strength vote = 0 when ADX is below its threshold; otherwise +1 when positive DI exceeds negative DI, −1 when negative DI exceeds positive DI, or 0 when equal
Calculation: Volume vote = +1 when volume is at least 1.2 times its moving average and close exceeds open; −1 when volume is at least 1.2 times its moving average and close is below open; otherwise 0
Calculation: Location vote = +1 when close is in the lowest 35% of the recent high-low range; −1 when in the highest 35%; otherwise 0
Calculation: Bullish agreement = count of positive factor votes among trend, RSI, MACD, strength, volume, and location
Calculation: Bearish agreement = count of negative factor votes among trend, RSI, MACD, strength, volume, and location
Calculation: Confluence score = weighted average of the six factor votes, scaled to −100..+100
Calculation: Smoothed confluence score = short-period EMA of confluence score
Long: Smoothed confluence score ≥ bullish threshold AND bullish agreement ≥ minimum agreement AND position side is not long
Short: Smoothed confluence score ≤ negative bullish threshold AND bearish agreement ≥ minimum agreement AND position side is not short
Exit: Long, low ≤ stop price OR high ≥ first target price
Exit: Short, high ≥ stop price OR low ≤ first target price