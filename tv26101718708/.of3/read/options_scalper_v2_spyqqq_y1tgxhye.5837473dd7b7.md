Calculation: Short EMA = EMA(close, shorter EMA lookback)
Calculation: Long EMA = EMA(close, longer EMA lookback)
Calculation: Trend EMA = EMA(close, separate trend EMA lookback)
Calculation: RSI = RSI(close, RSI lookback)
Calculation: VWAP = VWAP((high + low + close) / 3)
Calculation: Average volume = SMA(volume, volume lookback)
Calculation: MACD line, signal line, and histogram = MACD(close, shorter MACD lookback, longer MACD lookback, signal lookback)
Calculation: Stochastic %K = Stochastic(close, high, low, %K lookback)
Calculation: Stochastic %D = SMA(Stochastic %K, %D smoothing lookback)
Calculation: ATR = ATR(high, low, close, ATR lookback)
Calculation: Recent bullish EMA cross = Short EMA crossed above Long EMA on this chart bar or within the crossover lookback chart bars
Calculation: Recent bearish EMA cross = Short EMA crossed below Long EMA on this chart bar or within the crossover lookback chart bars
Calculation: Long score = crossover weight × recent bullish EMA cross + base weight × count of true conditions {Short EMA > Long EMA; RSI > bullish lower threshold AND RSI < bullish upper threshold; VWAP filter enabled AND close > VWAP; MACD line > signal line AND histogram > previous bar's histogram; volume > Average volume × volume multiplier AND close > open AND close − open > (high − low) × candle-body fraction threshold; (%K < oversold threshold AND %D < oversold threshold) OR %K > %D; close > Trend EMA; high > highest(high[1], structure lookback)}
Calculation: Short score = crossover weight × recent bearish EMA cross + base weight × count of true conditions {Short EMA < Long EMA; RSI < bearish upper threshold AND RSI > bearish lower threshold; VWAP filter enabled AND close < VWAP; MACD line < signal line AND histogram < previous bar's histogram; volume > Average volume × volume multiplier AND close < open AND open − close > (high − low) × candle-body fraction threshold; (%K > overbought threshold AND %D > overbought threshold) OR %K < %D; close < Trend EMA; low < lowest(low[1], structure lookback)}
Calculation: Signal-spacing counter = chart-bar counter initialized at zero, incremented before each bar's signal check, and reset to zero whenever either filtered signal fires
Long: Short EMA crosses above Long EMA
Short: Short EMA crosses below Long EMA
Long: Recent bullish EMA cross AND long score >= minimum score threshold AND long score > short score AND (session filter disabled OR chart bar is within either configured session) AND signal-spacing counter >= minimum signal spacing
Short: Recent bearish EMA cross AND short score >= minimum score threshold AND short score > long score AND (session filter disabled OR chart bar is within either configured session) AND signal-spacing counter >= minimum signal spacing
Calculation: Long stop = entry-signal-bar close − ATR on that bar × stop multiplier
Calculation: Long target = entry-signal-bar close + ATR on that bar × target multiplier
Calculation: Short stop = entry-signal-bar close + ATR on that bar × stop multiplier
Calculation: Short target = entry-signal-bar close − ATR on that bar × target multiplier
Exit: long, low <= Long stop OR high >= Long target
Exit: short, high >= Short stop OR low <= Short target