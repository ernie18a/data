Calculation: ST direction = direction of SuperTrend(hl2, ATR length, factor), up or down
Calculation: ST line = value of SuperTrend(hl2, ATR length, factor)
Calculation: band width = SuperTrend upper band - SuperTrend lower band
Calculation: compressed = band width - lowest(band width, compression lookback) <= compression threshold * (highest(band width, compression lookback) - lowest(band width, compression lookback))
Calculation: released = compressed[1] AND NOT compressed
Calculation: flipped = ST direction != ST direction[1]
Calculation: stretch = min(abs(close - ST line) / ATR(ATR length), distance cap)
Calculation: expanding = stretch > stretch[1]
Calculation: Up score = [ADX(DI length, ADX smoothing) >= ADX threshold AND +DI(DI length) > -DI(DI length)] + [close > VWAP(hlc3) AND close > ST line] + [expanding] + [released AND ST direction = up]
Calculation: Down score = [ADX(DI length, ADX smoothing) >= ADX threshold AND -DI(DI length) > +DI(DI length)] + [close < VWAP(hlc3) AND close < ST line] + [expanding] + [released AND ST direction = down]
Calculation: Up clue = [+DI(DI length) > -DI(DI length)] + [close > VWAP(hlc3)] + [close > close[1]] + [expanding]
Calculation: Down clue = [-DI(DI length) > +DI(DI length)] + [close < VWAP(hlc3)] + [close < close[1]] + [expanding]
Calculation: current score = Up score if ST direction = up, else Down score
Calculation: phase = Compressed Break if released AND current score >= compressed-break score; else Confirmed if flipped AND current score >= confirmed score; else Transition if flipped; else Exhausted if current score <= exhaustion ceiling; else None
Calculation: bull setup = phase = Exhausted AND Up clue >= clue threshold
Calculation: bear setup = phase = Exhausted AND Down clue >= clue threshold
Long: chart timeframe < T1 AND bull setup AND NOT bull setup[1] AND position side is not long
Short: chart timeframe < T1 AND bear setup AND NOT bear setup[1] AND position side is not short
Long: bull setup
Short: bear setup
Long: chart timeframe < T1 AND bull setup AND position side is long
Short: chart timeframe < T1 AND bear setup AND position side is short
Long: ST direction = up
Long: ST direction = up AND phase = Confirmed
Long: ST direction = up AND phase = None
Short: ST direction = down
Short: ST direction = down AND phase = Confirmed
Short: ST direction = down AND phase = None