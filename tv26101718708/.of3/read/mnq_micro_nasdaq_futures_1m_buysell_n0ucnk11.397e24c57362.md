Calculation: Fast EMA = EMA(close, fast EMA lookback); Mid EMA = EMA(close, mid EMA lookback); Slow EMA = EMA(close, slow EMA lookback), with fast lookback < mid lookback < slow lookback
Calculation: RSI = RSI(close, RSI lookback), with upper threshold > midpoint > lower threshold
Calculation: MACD histogram = MACD histogram(close, MACD fast lookback, MACD slow lookback, signal lookback), with fast lookback < slow lookback
Calculation: Stochastic %K = Stochastic %K(close, high, low, K lookback)
Calculation: Stochastic %D = SMA(Stochastic %K, D smoothing lookback)
Calculation: Bollinger Bands = Bollinger Bands(close, band lookback, deviation parameter)
Calculation: VWAP = VWAP(hlc3)
Calculation: Volume average = SMA(volume, volume lookback)
Calculation: Session gate = session filter disabled OR datetime is within configured session window in configured timezone
Calculation: Long score = count of true conditions: fast EMA > mid EMA AND mid EMA > slow EMA; fast EMA crosses above mid EMA; close > VWAP; (RSI > midpoint AND RSI < upper threshold) OR RSI < lower threshold; MACD histogram crosses above its baseline; MACD histogram > its baseline AND > its prior-bar value; Stochastic %K crosses above Stochastic %D AND %K < upper stochastic threshold; close <= lower Bollinger Band; volume > volume average * volume spike multiple AND close > open
Calculation: Short score = count of true conditions: fast EMA < mid EMA AND mid EMA < slow EMA; fast EMA crosses below mid EMA; close < VWAP; (RSI < midpoint AND RSI > lower threshold) OR RSI > upper threshold; MACD histogram crosses below its baseline; MACD histogram < its baseline AND < its prior-bar value; Stochastic %K crosses below Stochastic %D AND %K > lower stochastic threshold; close >= upper Bollinger Band; volume > volume average * volume spike multiple AND close < open
Long: Long score >= minimum confluence score AND Long score > Short score AND Session gate AND NOT (Long score on the prior bar >= minimum confluence score AND Long score on the prior bar > Short score on the prior bar AND Session gate on the prior bar)
Short: Short score >= minimum confluence score AND Short score > Long score AND Session gate AND NOT (Short score on the prior bar >= minimum confluence score AND Short score on the prior bar > Long score on the prior bar AND Session gate on the prior bar)