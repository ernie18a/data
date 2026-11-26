Calculation: Pair short EMA = EMA(monitored currency-pair close, shorter EMA lookback, current forming chart bar)
Calculation: Pair long EMA = EMA(monitored currency-pair close, longer EMA lookback, current forming chart bar)
Calculation: Pair stochastic main = Stochastic(monitored currency-pair high, monitored currency-pair low, K lookback, D smoothing lookback, slowing period, SMA, current forming chart bar).main
Calculation: Pair CCI = CCI(monitored currency-pair close, lookback, current forming chart bar)
Calculation: Pair RSI = RSI(monitored currency-pair close, lookback, current forming chart bar)
Calculation: Pair MACD main = MACD(monitored currency-pair close, shorter fast lookback, longer slow lookback, signal SMA lookback, current forming chart bar).main
Calculation: Pair MACD signal = MACD(monitored currency-pair close, shorter fast lookback, longer slow lookback, signal SMA lookback, current forming chart bar).signal
Long: Pair short EMA is greater than Pair long EMA
Short: Pair short EMA is less than Pair long EMA
Long: Pair stochastic main is greater than stochastic midpoint parameter AND Pair stochastic main is not equal to stochastic upper threshold parameter
Short: Pair stochastic main is less than stochastic midpoint parameter AND Pair stochastic main is not equal to stochastic lower threshold parameter
Long: Pair CCI is greater than CCI center parameter AND Pair CCI is not equal to CCI upper threshold parameter
Short: Pair CCI is less than CCI center parameter AND Pair CCI is not equal to CCI lower threshold parameter
Long: Pair RSI is greater than RSI midpoint parameter AND Pair RSI is not equal to RSI upper threshold parameter
Short: Pair RSI is less than RSI midpoint parameter AND Pair RSI is not equal to RSI lower threshold parameter
Long: Pair MACD main is greater than MACD zero threshold parameter AND Pair MACD main is not equal to Pair MACD signal
Short: Pair MACD main is less than MACD zero threshold parameter AND Pair MACD main is not equal to Pair MACD signal