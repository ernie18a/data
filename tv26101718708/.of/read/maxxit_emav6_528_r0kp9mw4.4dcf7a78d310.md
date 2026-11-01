Calculation: Rising(x, n) = x is greater than every value of x in the preceding n bars; falling(x, n) = x is less than every value of x in the preceding n bars.
Calculation: Volatility factor = a high, low, or normal multiplier selected by comparing ATR / close with a longer-lookback SMA of ATR / close times high and low thresholds.
Calculation: Momentum score = volatility factor times the sum of positive contributions for ADX above a trend threshold AND +DI > -DI, MACD histogram > 0 AND rising from its previous value, and fast RSI between a midpoint and an upper threshold, minus matching contributions for ADX above the threshold AND -DI > +DI, MACD histogram < 0 AND falling, and fast RSI between a lower threshold and the midpoint. The directional-movement contribution is larger than either of the other contributions.
Calculation: Initial stop and target = the signal-bar close adjusted down and up, respectively, for a long, or up and down for a short, by separate stop and target percentages multiplied by the signal bar's volatility factor; retain these levels while adding to the position.
Calculation: Manual long trailing stop = initial stop until close exceeds average entry price plus a trailing activation distance; thereafter the highest observed value of initial stop + close - average entry price on bars satisfying that activation condition. Manual short trailing stop = initial stop until close falls below average entry price minus the activation distance; thereafter the lowest observed value of initial stop - (average entry price - close) on bars satisfying that activation condition.
Long: Trend EMA is rising over its lookback AND fast EMA on the previous bar < trigger EMA on the previous bar AND fast EMA > trigger EMA AND (setback disabled OR (previous low < previous fast EMA AND close > fast EMA AND fast EMA > trend EMA)).
Short: Trend EMA is falling over its lookback AND fast EMA on the previous bar > trigger EMA on the previous bar AND fast EMA < trigger EMA AND (setback disabled OR (previous high > previous fast EMA AND close < fast EMA AND fast EMA < trend EMA)).
Long: Re-entry enabled AND at least one stop or target enabled AND position is flat AND trend EMA is rising AND fast EMA is rising over a shorter lookback AND high is rising over the same shorter lookback AND abs(fast EMA - trend EMA) / ATR <= an overextension threshold AND fast EMA > trend EMA AND fast EMA from the shorter lookback bars ago > current trend EMA AND previous low < previous fast EMA AND close > fast EMA.
Short: Re-entry enabled AND at least one stop or target enabled AND position is flat AND trend EMA is falling AND fast EMA is falling over a shorter lookback AND low is falling over the same shorter lookback AND abs(fast EMA - trend EMA) / ATR <= an overextension threshold AND fast EMA < trend EMA AND fast EMA from the shorter lookback bars ago < current trend EMA AND previous high > previous fast EMA AND close < fast EMA.
Long: Trading disabled AND trigger EMA > longer EMA AND previous trigger EMA < previous longer EMA.
Short: Trading disabled AND trigger EMA < longer EMA AND previous trigger EMA > previous longer EMA.
Long: Trigger EMA > previous trigger EMA OR longer EMA > previous longer EMA.
Short: Trigger EMA < previous trigger EMA OR longer EMA < previous longer EMA.
Long: ADX > trend threshold AND +DI > -DI.
Short: ADX > trend threshold AND +DI <= -DI.
Long: Momentum score > positive threshold.
Short: Momentum score < negative threshold.
Long: Volume price trend > its EMA.
Short: Volume price trend < its EMA.
Exit: long, short entry condition is met.
Exit: short, long entry condition is met.
Exit: long, close >= initial target.
Exit: short, close <= initial target.
Exit: long, manual stop enabled AND close <= manual long trailing stop.
Exit: short, manual stop enabled AND close >= manual short trailing stop.
Exit: long, automatic stop enabled AND (low <= initial stop OR high >= initial target OR (standard entry AND high reaches entry price plus trailing activation distance AND subsequent low <= highest high since activation minus trailing offset)).
Exit: short, automatic stop enabled AND (high >= initial stop OR low <= initial target OR (standard entry AND low reaches entry price minus trailing activation distance AND subsequent high >= lowest low since activation plus trailing offset)).