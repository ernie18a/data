Calculation: DI spread = +DI(high, low, close, DMI length) minus -DI(high, low, close, DMI length)
Calculation: ATR ratio = ATR(high, low, close, ATR length) / SMA(ATR(high, low, close, ATR length), ATR baseline length)
Calculation: Volume ratio = volume / SMA(volume, Volume MA length)
Calculation: Price-to-MA distance = (close - SMA(close, Trend MA length)) / ATR(high, low, close, ATR length)
Calculation: Tree 1 vote = +1 if RSI(close, RSI length) < RSI oversold level; else -1 if RSI(close, RSI length) > RSI overbought level; else 0
Calculation: Tree 2 vote = sign(MACD histogram(close, MACD fast length, MACD slow length, MACD signal length))
Calculation: Tree 3 vote = +1 if RSI(close, RSI length) < RSI long-zone level AND MACD histogram(close, MACD fast length, MACD slow length, MACD signal length) > 0; else -1 if RSI(close, RSI length) > RSI short-zone level AND MACD histogram(close, MACD fast length, MACD slow length, MACD signal length) < 0; else 0
Calculation: Tree 4 vote = +1 if DI spread > DI threshold; else -1 if DI spread < -DI threshold; else 0
Calculation: Tree 5 vote = +1 if Price-to-MA distance > Price-MA threshold; else -1 if Price-to-MA distance < -Price-MA threshold; else 0
Calculation: Tree 6 vote = sign(MACD histogram(close, MACD fast length, MACD slow length, MACD signal length)) if Volume ratio > Confirming volume ratio; else 0
Calculation: Tree 7 vote = +1 if RSI(close, RSI length) > RSI midline AND RSI(close, RSI length) > RSI(close, RSI length)[1]; else -1 if RSI(close, RSI length) < RSI midline AND RSI(close, RSI length) < RSI(close, RSI length)[1]; else 0
Calculation: Tree 8 vote = +1 if ATR ratio < ATR ratio cap AND DI spread > Filtered DI threshold; else -1 if ATR ratio < ATR ratio cap AND DI spread < -Filtered DI threshold; else 0
Calculation: Tree 9 vote = -1 if Price-to-MA distance > Extended price-MA threshold AND RSI(close, RSI length) > RSI extended-high level; else +1 if Price-to-MA distance < -Extended price-MA threshold AND RSI(close, RSI length) < RSI extended-low level; else 0
Calculation: Tree 10 vote = sign(MACD histogram(close, MACD fast length, MACD slow length, MACD signal length)) if Volume ratio > Volume surge ratio; else 0
Calculation: Tree 11 vote = +1 if RSI(close, RSI length) > RSI midline AND RSI(close, RSI length) < RSI overbought level; else -1 if RSI(close, RSI length) < RSI midline AND RSI(close, RSI length) > RSI oversold level; else 0
Calculation: Tree 12 vote = sign(DI spread) if Volume ratio > Above-average volume ratio; else 0
Calculation: Tree 13 vote = +1 if MACD histogram(close, MACD fast length, MACD slow length, MACD signal length) > 0 AND Price-to-MA distance > 0; else -1 if MACD histogram(close, MACD fast length, MACD slow length, MACD signal length) < 0 AND Price-to-MA distance < 0; else 0
Calculation: Tree 14 vote = +1 if ATR ratio < Calm ATR ratio cap AND RSI(close, RSI length) < RSI oversold level; else -1 if ATR ratio < Calm ATR ratio cap AND RSI(close, RSI length) > RSI overbought level; else 0
Calculation: Tree 15 vote = +1 if DI spread > 0 AND MACD histogram(close, MACD fast length, MACD slow length, MACD signal length) > 0 AND Price-to-MA distance > 0; else -1 if DI spread < 0 AND MACD histogram(close, MACD fast length, MACD slow length, MACD signal length) < 0 AND Price-to-MA distance < 0; else 0
Calculation: Tree i graded count = number of bars up to the current bar where Tree i vote[Outcome window] != 0
Calculation: Tree i hit count = number of bars up to the current bar where (Tree i vote[Outcome window] > 0 AND close > close[Outcome window]) OR (Tree i vote[Outcome window] < 0 AND close < close[Outcome window])
Calculation: Tree i weight = Neutral weight if Tree i graded count < Minimum graded samples; else Tree i hit count / Tree i graded count
Calculation: Bull score = sum of Tree i weight over trees i where Tree i vote > 0
Calculation: Bear score = sum of Tree i weight over trees i where Tree i vote < 0
Calculation: Bull share = 50 if Bull score + Bear score = 0; else 100 * Bull score / (Bull score + Bear score)
Calculation: Verdict = BULLISH if Bull share >= Bull threshold; else BEARISH if Bull share <= Bear threshold; else NEUTRAL
Calculation: Bull confluence = (Verdict = BULLISH) AND (RSI(close, RSI length) < RSI oversold level)
Calculation: Bear confluence = (Verdict = BEARISH) AND (RSI(close, RSI length) > RSI overbought level)
Long: Verdict = BULLISH
Long: Bull confluence AND NOT Bull confluence[1]
Long: Bull confluence AND NOT Bull confluence[1] AND (no earlier long marker OR bars since the last long marker >= Signal cooldown) AND no marker fired on an earlier bar since the verdict last changed
Short: Verdict = BEARISH
Short: Bear confluence AND NOT Bear confluence[1]
Short: Bear confluence AND NOT Bear confluence[1] AND (no earlier short marker OR bars since the last short marker >= Signal cooldown) AND no marker fired on an earlier bar since the verdict last changed