Calculation: BB expansion = short-term Bollinger upper band > long-term Bollinger upper band AND short-term Bollinger lower band < long-term Bollinger lower band; short-term lookback is shorter than long-term lookback
Calculation: Recent BB expansion = BB expansion is true on the current bar or any of the preceding bars within the configured validity lookback
Calculation: Trend EMA = EMA of close on a higher timeframe, using the last completed higher-timeframe bar
Calculation: Smoothed trend EMA = EMA of Trend EMA, using a shorter lookback than Trend EMA
Calculation: ATR stop and target levels = on the first bar in a position, fix levels from that bar's close using ATR: stop distance is the configured ATR multiple, and target distance is stop distance multiplied by the configured risk/reward ratio
Long: Recent BB expansion AND open < short-term Bollinger basis AND close > short-term Bollinger basis AND Trend EMA >= Smoothed trend EMA
Short: Recent BB expansion AND open > short-term Bollinger basis AND close < short-term Bollinger basis AND Trend EMA < Smoothed trend EMA
Exit: long, low <= fixed ATR stop level OR high >= fixed ATR target level OR price reaches the configured bracket stop or target distance below or above entry price, respectively
Exit: short, high >= fixed ATR stop level OR low <= fixed ATR target level OR price reaches the configured bracket stop or target distance above or below entry price, respectively