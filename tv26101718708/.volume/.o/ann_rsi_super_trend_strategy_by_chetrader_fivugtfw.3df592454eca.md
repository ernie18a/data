Calculation: ANN score = feed-forward tanh network of one-bar percentage changes in volume, lower/middle/upper Bollinger bands, RSI, and MACD histogram
Calculation: Seed = ANN score − 100 × one-bar percentage change in close
Calculation: RSI offset = multiplier × RSI of Seed
Calculation: Long stop = hl2 − RSI offset, raised to at least the prior long stop if prior close > prior long stop; otherwise hl2 − RSI offset
Calculation: Short stop = hl2 + RSI offset, lowered to at most the prior short stop if prior close < prior short stop; otherwise hl2 + RSI offset
Calculation: Direction = +1 initially; thereafter +1 if prior direction = −1 and close > prior short stop, −1 if prior direction = +1 and close < prior long stop, otherwise prior direction
Long: bar time is within the configured test period AND prior direction = −1 AND direction = +1
Short: bar time is within the configured test period AND prior direction = +1 AND direction = −1
Exit: long position, prior direction = +1 AND direction = −1
Exit: short position, prior direction = −1 AND direction = +1