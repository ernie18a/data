Calculation: ATR ratio = current ATR divided by its moving average over a longer lookback
Calculation: Volume ratio = current volume divided by its moving average
Calculation: Price distance = (close − moving average of close) divided by ATR
Calculation: Directional difference = +DI − −DI
Calculation: Vote 1 = bullish if RSI is below its oversold threshold; bearish if above its overbought threshold; otherwise neutral
Calculation: Vote 2 = bullish if MACD histogram > 0; bearish if < 0; otherwise neutral
Calculation: Vote 3 = bullish if RSI < 40 AND MACD histogram > 0; bearish if RSI > 60 AND MACD histogram < 0; otherwise neutral
Calculation: Vote 4 = bullish if directional difference > 5; bearish if < −5; otherwise neutral
Calculation: Vote 5 = bullish if price distance > 0.5; bearish if < −0.5; otherwise neutral
Calculation: Vote 6 = bullish if MACD histogram > 0 AND volume ratio > 1.2; bearish if MACD histogram < 0 AND volume ratio > 1.2; otherwise neutral
Calculation: Vote 7 = bullish if RSI > 50 AND RSI is rising; bearish if RSI < 50 AND RSI is falling; otherwise neutral
Calculation: Vote 8 = bullish if ATR ratio < 1.5 AND directional difference > 3; bearish if ATR ratio < 1.5 AND directional difference < −3; otherwise neutral
Calculation: Vote 9 = bullish if price distance < −1 AND RSI < 35; bearish if price distance > 1 AND RSI > 65; otherwise neutral
Calculation: Vote 10 = bullish if volume ratio > 2 AND MACD histogram > 0; bearish if volume ratio > 2 AND MACD histogram < 0; otherwise neutral
Calculation: Vote 11 = bullish if RSI > 50 AND RSI < 70; bearish if RSI < 50 AND RSI > 30; otherwise neutral
Calculation: Vote 12 = bullish if directional difference > 0 AND volume ratio > 1; bearish if directional difference < 0 AND volume ratio > 1; otherwise neutral
Calculation: Vote 13 = bullish if MACD histogram > 0 AND price distance > 0; bearish if MACD histogram < 0 AND price distance < 0; otherwise neutral
Calculation: Vote 14 = bullish if ATR ratio < 1.2 AND RSI is below its oversold threshold; bearish if ATR ratio < 1.2 AND RSI is above its overbought threshold; otherwise neutral
Calculation: Vote 15 = bullish if directional difference > 0 AND MACD histogram > 0 AND price distance > 0; bearish if directional difference < 0 AND MACD histogram < 0 AND price distance < 0; otherwise neutral
Calculation: Vote weight = hit count divided by graded non-neutral votes when the count reaches a minimum sample threshold; otherwise 0.5. A vote is a hit when its direction matches the sign of the close change from its bar to the close after a forward outcome window.
Calculation: Bullish share = 100 × weighted sum of bullish votes divided by weighted sum of all non-neutral votes; if there are no non-neutral votes, bullish share = 50%
Long: Bullish share ≥ bullish threshold OR Vote 1 is bullish OR Vote 3 is bullish OR Vote 4 is bullish OR Vote 9 is bullish OR Vote 15 is bullish
Short: Bullish share ≤ bearish threshold OR Vote 1 is bearish OR Vote 3 is bearish OR Vote 4 is bearish OR Vote 9 is bearish OR Vote 15 is bearish