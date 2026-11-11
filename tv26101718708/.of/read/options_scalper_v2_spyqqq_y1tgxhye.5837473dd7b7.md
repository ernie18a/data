Calculation: Recent upward crossover = bars since the short EMA crossed above the longer EMA <= crossover lookback.
Calculation: Recent downward crossover = bars since the short EMA crossed below the longer EMA <= crossover lookback.
Calculation: Bullish score = 2 if recent upward crossover, plus 1 for each of: short EMA > longer EMA; RSI > bullish lower threshold AND RSI < overbought threshold; VWAP scoring enabled AND close > session VWAP of (high + low + close) / 3; MACD line > signal line AND MACD histogram > previous histogram; volume > volume SMA * volume multiplier AND close > open AND close - open > (high - low) * body fraction; stochastic K and D both < oversold threshold OR K > D; close > long-term EMA; high > highest high over the preceding lookback bars.
Calculation: Bearish score = 2 if recent downward crossover, plus 1 for each of: short EMA < longer EMA; RSI < bearish upper threshold AND RSI > oversold threshold; VWAP scoring enabled AND close < session VWAP of (high + low + close) / 3; MACD line < signal line AND MACD histogram < previous histogram; volume > volume SMA * volume multiplier AND close < open AND open - close > (high - low) * body fraction; stochastic K and D both > overbought threshold OR K < D; close < long-term EMA; low < lowest low over the preceding lookback bars. The RSI thresholds are ordered oversold, bullish lower, bearish upper, overbought; stochastic D is an SMA of K.
Calculation: Bullish signal = recent upward crossover AND bullish score >= minimum score AND bullish score > bearish score AND session filtering disabled OR recent upward crossover AND bullish score >= minimum score AND bullish score > bearish score AND bar opens within either configured session in the exchange timezone; additionally, bars since the previous bullish or bearish signal >= cooldown, counting from the start of the data if no signal has occurred.
Calculation: Bearish signal = recent downward crossover AND bearish score >= minimum score AND bearish score > bullish score AND session filtering disabled OR recent downward crossover AND bearish score >= minimum score AND bearish score > bullish score AND bar opens within either configured session in the exchange timezone; additionally, bars since the previous bullish or bearish signal >= cooldown, counting from the start of the data if no signal has occurred.
Calculation: Exit levels = signal-bar close minus or plus signal-bar ATR multiplied by the respective stop or target multiplier; fix these levels when the flat-position entry signal occurs.
Long: short EMA crosses above longer EMA.
Short: short EMA crosses below longer EMA.
Long: bullish score >= minimum score.
Short: bearish score >= minimum score.
Long: RSI < oversold threshold.
Short: RSI > overbought threshold.
Long: MACD line > signal line AND MACD histogram > previous histogram.
Short: MACD line < signal line AND MACD histogram < previous histogram.
Long: stochastic K < oversold threshold AND stochastic D < oversold threshold.
Short: stochastic K > overbought threshold AND stochastic D > overbought threshold.
Long: close > session VWAP of (high + low + close) / 3.
Short: close < session VWAP of (high + low + close) / 3.
Long: close > long-term EMA.
Short: close < long-term EMA.
Long: recent upward crossover.
Short: recent downward crossover AND recent upward crossover is false.
Long: bullish signal.
Short: bearish signal.
Exit: long, bearish signal OR low <= fixed long stop OR high >= fixed long target.
Exit: short, bullish signal OR high >= fixed short stop OR low <= fixed short target.