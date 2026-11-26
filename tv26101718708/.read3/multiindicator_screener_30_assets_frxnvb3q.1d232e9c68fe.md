Calculation: RSI value = RSI(close, RSI lookback)
Calculation: RSI SMA = SMA(RSI value, RSI SMA lookback)
Calculation: MACD histogram = histogram of MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback)
Calculation: Price range = highest(high, price range lookback) − lowest(low, price range lookback)
Calculation: EMA slope angle = atan((EMA(close, EMA lookback) − EMA(close, EMA lookback)[slope lookback]) / (Price range / price range lookback × slope lookback)) × 180 / π
Calculation: OBV short MA = MA(OBV, OBV short lookback, OBV MA type)
Calculation: OBV long MA = MA(OBV, OBV long lookback, OBV MA type)
Calculation: Supertrend line = Supertrend(Supertrend factor, Supertrend ATR lookback)
Calculation: VWAP = session VWAP(high, low, close, volume)
Calculation: Plus DI = +DI(DI lookback)
Calculation: Minus DI = −DI(DI lookback)
Calculation: ADX = ADX(DI lookback, ADX smoothing lookback)
Calculation: Bollinger %B = (close − lower band) / (upper band − lower band), where bands = Bollinger(close, Bollinger lookback, Bollinger multiplier), and BB midline when upper band ≤ lower band
Calculation: Stoch RSI K = SMA(Stochastic(RSI(close, Stoch RSI lookback), stoch lookback), K smoothing lookback)
Calculation: Stoch RSI D = SMA(Stoch RSI K, D smoothing lookback)
Calculation: Close position = (2 × close − high − low) / (high − low), or 0 when high ≤ low
Calculation: Smoothed close position = EMA(Close position, Vol Delta smoothing lookback)
Calculation: Indicator state = neutral while any value it uses is undefined; RSI: strong bull if RSI value > RSI SMA AND RSI value > RSI midline, else weak bull if RSI value > RSI SMA OR RSI value > RSI midline, else strong bear if RSI value < RSI SMA AND RSI value < RSI midline, else weak bear if RSI value < RSI SMA OR RSI value < RSI midline, else neutral; MACD: strong bull if MACD histogram ≥ 0 AND MACD histogram > MACD histogram[1], else weak bull if MACD histogram ≥ 0, else strong bear if MACD histogram < MACD histogram[1], else weak bear; EMA slope: neutral if Price range ≤ 0, else strong bull if EMA slope angle ≥ reference angle, else weak bull if EMA slope angle > 0, else strong bear if EMA slope angle ≤ −reference angle, else weak bear if EMA slope angle < 0, else neutral; OBV Trend: strong bull if OBV short MA > OBV long MA AND OBV long MA > OBV long MA[1], else weak bull if OBV short MA > OBV long MA, else strong bear if OBV short MA < OBV long MA AND OBV long MA < OBV long MA[1], else weak bear if OBV short MA < OBV long MA, else neutral; Supertrend: strong bull if close > Supertrend line AND close > close[1], else weak bull if close > Supertrend line, else strong bear if close ≤ close[1], else weak bear; VWAP: strong bull if close > VWAP AND close > close[1], else weak bull if close > VWAP, else strong bear if close ≤ close[1], else weak bear; ADX/DMI: strong bull if Plus DI > Minus DI AND ADX ≥ ADX threshold, else weak bull if Plus DI > Minus DI, else strong bear if ADX ≥ ADX threshold, else weak bear; Bollinger %B: strong bull if Bollinger %B ≥ 1, else weak bull if Bollinger %B ≥ BB midline, else strong bear if Bollinger %B ≤ 0, else weak bear; Stoch RSI: strong bull if Stoch RSI K > Stoch RSI D AND Stoch RSI K > stoch midline, else weak bull if Stoch RSI K > Stoch RSI D OR Stoch RSI K > stoch midline, else strong bear if Stoch RSI K < Stoch RSI D AND Stoch RSI K < stoch midline, else weak bear if Stoch RSI K < Stoch RSI D OR Stoch RSI K < stoch midline, else neutral; Vol Delta: strong bull if Smoothed close position > Vol Delta threshold AND Smoothed close position > Smoothed close position[1], else weak bull if Smoothed close position > 0, else strong bear if Smoothed close position < −Vol Delta threshold AND Smoothed close position < Smoothed close position[1], else weak bear if Smoothed close position < 0, else neutral
Calculation: Breadth count(S) = number of basket instruments whose Indicator state = S
Calculation: Bull breadth count = Breadth count(strong bull) + Breadth count(weak bull)
Calculation: Bear breadth count = Breadth count(strong bear) + Breadth count(weak bear)
Calculation: Breadth share(S) = 100 × Breadth count(S) / basket size
Calculation: Market status = MIXED if Bull breadth count = Bear breadth count, else STRONG BULL if Bull breadth count > Bear breadth count AND Breadth count(strong bull) ≥ Breadth count(weak bull), else WEAK BULL if Bull breadth count > Bear breadth count, else STRONG BEAR if Breadth count(strong bear) ≥ Breadth count(weak bear), else WEAK BEAR
Calculation: Momentum score = round((2 × Breadth count(strong bull) + Breadth count(weak bull) − Breadth count(weak bear) − 2 × Breadth count(strong bear) + 2 × basket size) / (4 × basket size) × 100)
Calculation: Group bull count(a, b) = number of basket instruments at positions a through b whose Indicator state is strong bull or weak bull
Calculation: Group bear count(a, b) = number of basket instruments at positions a through b whose Indicator state is strong bear or weak bear
Long: Indicator state = strong bull
Long: Indicator state = weak bull
Short: Indicator state = weak bear
Short: Indicator state = strong bear
Long: (Indicator state = strong bull OR Indicator state = weak bull) AND Bull breadth count ≤ Bear breadth count
Short: (Indicator state = strong bear OR Indicator state = weak bear) AND Bull breadth count > Bear breadth count
Long: Breadth count(strong bull) ≥ minimum count
Short: Breadth count(strong bear) ≥ minimum count
Long: Breadth share(strong bull) ≥ extreme share AND Breadth share(strong bull)[1] < extreme share
Short: Breadth share(strong bear) ≥ extreme share AND Breadth share(strong bear)[1] < extreme share
Long: (Market status = STRONG BULL OR Market status = WEAK BULL) AND Market status ≠ Market status[1] AND Market status[1] is defined
Short: (Market status = STRONG BEAR OR Market status = WEAK BEAR) AND Market status ≠ Market status[1] AND Market status[1] is defined
Long: Market status = STRONG BULL
Long: Market status = WEAK BULL
Short: Market status = STRONG BEAR
Short: Market status = WEAK BEAR
Long: Momentum score ≥ momentum high
Short: Momentum score < momentum low
Long: Group bull count(1, 4) > Group bear count(1, 4)
Short: Group bear count(1, 4) > Group bull count(1, 4)
Long: Group bull count(5, 10) > Group bear count(5, 10)
Short: Group bear count(5, 10) > Group bull count(5, 10)
Long: Group bull count(11, 17) > Group bear count(11, 17)
Short: Group bear count(11, 17) > Group bull count(11, 17)
Long: Group bull count(18, 22) > Group bear count(18, 22)
Short: Group bear count(18, 22) > Group bull count(18, 22)
Long: Group bull count(23, 24) > Group bear count(23, 24)
Short: Group bear count(23, 24) > Group bull count(23, 24)
Long: Group bull count(25, 30) > Group bear count(25, 30)
Short: Group bear count(25, 30) > Group bull count(25, 30)