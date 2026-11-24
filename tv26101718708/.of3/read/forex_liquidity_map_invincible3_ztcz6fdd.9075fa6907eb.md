Calculation: Pair relative tick volume = clip(volume / SMA(volume, volume lookback), relative-volume lower bound, relative-volume upper bound)
Calculation: Normalized momentum = clip(((close - close[momentum lookback]) / ATR(ATR lookback)) / momentum scale, normalized lower bound, normalized upper bound)
Calculation: Signed relative-volume pressure = clip((pair relative tick volume - 1) × sign(normalized momentum) / volume scale, normalized lower bound, normalized upper bound)
Calculation: Normalized trend = clip(((EMA(close, shorter trend lookback) - EMA(close, longer trend lookback)) / ATR(ATR lookback)) / trend scale, normalized lower bound, normalized upper bound)
Calculation: Volatility expansion = clip((ATR(ATR lookback) / close) / SMA(ATR(ATR lookback) / close, volume lookback) - 1, normalized lower bound, normalized upper bound) × sign(normalized momentum)
Calculation: Directional breadth = positive breadth value if close > EMA(close, shorter trend lookback), otherwise negative breadth value
Calculation: Pair flow score = score scale × EMA(weighted mean of normalized momentum, signed relative-volume pressure, normalized trend, volatility expansion and directional breadth using their separate weights; zero total weight gives zero; compute on T1 bars and carry to chart bars using the last completed T1 bar in confirmed mode or the forming T1 bar in live mode)
Calculation: Currency flow score = the mean of valid pair flow scores for that currency, adding a score when it is the base currency and subtracting it when it is the quote currency; clamp to the currency-score bounds across USD, EUR, GBP, JPY, CHF, CAD, AUD and NZD
Calculation: Currency flow acceleration = current currency flow score minus its value acceleration lookback T1 bars earlier
Calculation: River strength = (currency-spread weight × abs(base currency flow score - quote currency flow score) + pair-score weight × abs(pair flow score)) × clip(pair relative tick volume, river activity lower bound, river activity upper bound)
Long: pair flow score >= pair signal threshold
Short: pair flow score <= -pair signal threshold
Long: currency flow score > currency signal threshold
Short: currency flow score < -currency signal threshold
Long: base currency flow score is highest among the eight currencies AND quote currency flow score is lowest among the eight currencies; break ties in USD, EUR, GBP, JPY, CHF, CAD, AUD, NZD order
Short: quote currency flow score is highest among the eight currencies AND base currency flow score is lowest among the eight currencies; break ties in USD, EUR, GBP, JPY, CHF, CAD, AUD, NZD order
Long: base currency flow score > quote currency flow score AND river strength >= minimum river strength
Short: base currency flow score < quote currency flow score AND river strength >= minimum river strength
Long: highest currency flow score >= strong-currency alert threshold AND its currency flow acceleration > 0
Short: lowest currency flow score <= -strong-currency alert threshold AND its currency flow acceleration < 0