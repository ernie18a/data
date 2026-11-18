Calculation: MACD regime score = if MACD line > 0 then (MACD line > MACD signal ? 1 : 0) else (MACD line > MACD signal ? 0 : -1), where MACD line = EMA(close, shorter lookback) - EMA(close, longer lookback) and MACD signal = EMA(MACD line, signal lookback)
Calculation: MACD momentum score = if MACD histogram >= 0 then (MACD histogram > MACD histogram[1] ? 1 : 0) else (MACD histogram > MACD histogram[1] ? 0 : -1), where MACD histogram = MACD line - MACD signal
Calculation: RSI regime score = RSI(close, lookback) smoothed by EMA(short lookback) > upper threshold ? 1 : RSI(close, lookback) smoothed by EMA(short lookback) < lower threshold ? -1 : 0
Calculation: EMA trend score = EMA(close, shorter lookback) > EMA(close, longer lookback) ? 1 : -1
Calculation: ADX activity score = ADX(DMI lookback, smoothing lookback) > EMA(ADX(DMI lookback, smoothing lookback), lookback) ? (close > EMA(close, lookback) ? 1 : -1) : 0
Calculation: Williams %R score = EMA(Williams %R(close, high, low, lookback), short lookback) > negative upper threshold ? 1 : EMA(Williams %R(close, high, low, lookback), lookback) < negative lower threshold ? -1 : 0
Calculation: Chaikin money flow score = Chaikin Money Flow(high, low, close, volume, lookback) > upper threshold ? 1 : Chaikin Money Flow(high, low, close, volume, lookback) < negative lower threshold ? -1 : 0
Calculation: Majority score = MACD regime score + MACD momentum score + RSI regime score + EMA trend score + ADX activity score + Williams %R score + Chaikin money flow score + Supertrend direction(high, low, close, ATR lookback, multiplier)
Calculation: Adjusted score = if (Majority score >= 0 and Majority score[1] <= 0) or (Majority score <= 0 and Majority score[1] >= 0) then 0 else Majority score
Calculation: Level = if previous Level is nonzero then 0 else if Adjusted score[1] < 0 and Adjusted score >= 0 then high × (1 + offset) else if Adjusted score[1] > 0 and Adjusted score <= 0 then low × (1 - offset) else previous Level
Calculation: Level color = if Adjusted score[1] < 0 and Adjusted score >= 0 then green else if Adjusted score[1] > 0 and Adjusted score <= 0 then red else previous Level color, initially green
Long: flat AND ((high > Level AND Level color is green) OR (Adjusted score[1] > 0 AND Adjusted score > 0))
Exit: long, (low < Level AND Level color is red) OR (Adjusted score[1] < 0 AND Adjusted score < 0)