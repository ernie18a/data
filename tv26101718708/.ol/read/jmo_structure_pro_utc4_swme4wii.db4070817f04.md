Calculation: Short-term, medium-term, and long-term EMA = exponential moving averages of close, with progressively longer lookbacks.
Calculation: Bollinger upper band = close-based Bollinger Bands upper band, using a lookback and standard-deviation multiplier.
Calculation: Higher-timeframe EMA band = range between the fast and slow EMAs calculated from a higher-timeframe bar that may still be forming.
Calculation: Strong push candle = candle body at least the configured multiple of the 20-bar average candle body.
Calculation: Demand base = a red candle inside an enabled session, within the configured lookback, with neither adjacent candle red; supply base = a green candle inside an enabled session, within the configured lookback, with neither adjacent candle green.
Long: Short-term EMA > long-term EMA
Long: Short-term EMA > medium-term EMA AND medium-term EMA > long-term EMA
Long: Strong green push candle AND its close is above the high of a demand base
Long: Short-term EMA or long-term EMA enters a higher-timeframe EMA band on the current chart bar, having been outside that band on the prior chart bar
Short: Short-term EMA <= long-term EMA
Short: Short-term EMA < medium-term EMA AND medium-term EMA < long-term EMA
Short: Strong red push candle AND its close is below the low of a supply base
Exit: