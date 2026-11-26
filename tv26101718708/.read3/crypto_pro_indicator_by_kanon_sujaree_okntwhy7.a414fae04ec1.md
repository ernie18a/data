Calculation: Chart RSI = RSI(close, RSI length) on chart bars
Calculation: Higher-timeframe RSI = RSI(close, RSI length, T1 current bar), sampled on chart bars with lookahead off; it can use the still-forming T1 bar in realtime and its final value after completion
Calculation: MACD outputs = MACD(close, fast lookback, slow lookback, signal lookback) on chart bars
Calculation: DMI outputs = DMI(DMI lookback, ADX smoothing lookback) on chart bars
Calculation: Latest confirmed swing high = most recent non-missing PivotHigh(high, swing lookback, swing lookback) on chart bars
Calculation: Latest confirmed swing low = most recent non-missing PivotLow(low, swing lookback, swing lookback) on chart bars
Calculation: Bullish structure state = initially bullish; on each chart bar set bullish if close crosses above the latest confirmed swing high, then set bearish if close crosses below the latest confirmed swing low
Calculation: ADX strength points = ADX >= highest ADX tier threshold ? highest ADX tier points : ADX >= middle ADX tier threshold ? middle ADX tier points : ADX >= lowest ADX tier threshold ? lowest ADX tier points : 0
Calculation: Long DMI points = +DI > -DI ? ADX strength points : round(half of ADX strength points)
Calculation: Short DMI points = -DI > +DI ? ADX strength points : round(half of ADX strength points)
Calculation: Long VWAP points = close > hlc3 AND low <= hlc3 * lower-band proximity factor ? full VWAP points : close > hlc3 ? base VWAP points : 0
Calculation: Short VWAP points = close < hlc3 AND high >= hlc3 * upper-band proximity factor ? full VWAP points : close < hlc3 ? base VWAP points : 0
Calculation: Long RSI points = Chart RSI < oversold threshold AND Higher-timeframe RSI > RSI midpoint ? full RSI points : Chart RSI > RSI midpoint AND Chart RSI < overbought threshold AND Higher-timeframe RSI > RSI midpoint ? base RSI points : 0
Calculation: Short RSI points = Chart RSI > overbought threshold AND Higher-timeframe RSI < RSI midpoint ? full RSI points : Chart RSI < RSI midpoint AND Chart RSI > oversold threshold AND Higher-timeframe RSI < RSI midpoint ? base RSI points : 0
Calculation: Long MACD points = MACD line crosses above MACD signal line ? full MACD points : MACD line > MACD signal line AND MACD histogram > its previous chart-bar value AND MACD histogram > zero line ? base MACD points : 0
Calculation: Short MACD points = MACD line crosses below MACD signal line ? full MACD points : MACD line < MACD signal line AND MACD histogram < its previous chart-bar value AND MACD histogram < zero line ? base MACD points : 0
Calculation: Long structure points = close crosses above latest confirmed swing high ? full structure points : bullish structure state ? base structure points : 0
Calculation: Short structure points = close crosses below latest confirmed swing low ? full structure points : bullish structure state ? 0 : base structure points
Calculation: Long EMA points = close > EMA(close, EMA length) AND EMA(close, EMA length) > its value at the slope lookback bars ago ? full EMA points : close > EMA(close, EMA length) ? base EMA points : 0
Calculation: Short EMA points = close < EMA(close, EMA length) AND EMA(close, EMA length) < its value at the slope lookback bars ago ? full EMA points : close < EMA(close, EMA length) ? base EMA points : 0
Calculation: Long volume points = close > open AND volume > SMA(volume, volume lookback) * high-volume ratio ? high-volume points : close > open AND volume >= SMA(volume, volume lookback) * normal-volume lower ratio AND volume <= SMA(volume, volume lookback) * high-volume ratio ? normal-volume points : 0
Calculation: Short volume points = close < open AND volume > SMA(volume, volume lookback) * high-volume ratio ? high-volume points : close < open AND volume >= SMA(volume, volume lookback) * normal-volume lower ratio AND volume <= SMA(volume, volume lookback) * high-volume ratio ? normal-volume points : 0
Calculation: Bullish RSI divergence points = low < lowest(low, divergence lookback) on the previous chart bar AND Chart RSI > lowest(Chart RSI, divergence lookback) on the previous chart bar AND Chart RSI < bullish divergence RSI ceiling ? divergence points : 0
Calculation: Bearish RSI divergence points = high > highest(high, divergence lookback) on the previous chart bar AND Chart RSI < highest(Chart RSI, divergence lookback) on the previous chart bar AND Chart RSI > bearish divergence RSI floor ? divergence points : 0
Calculation: Long confidence = round(Long VWAP points + Long RSI points + Long MACD points + Long DMI points + Long structure points + Long EMA points + Long volume points + Bullish RSI divergence points)
Calculation: Short confidence = round(Short VWAP points + Short RSI points + Short MACD points + Short DMI points + Short structure points + Short EMA points + Short volume points + Bearish RSI divergence points)
Long: Long confidence >= confidence threshold AND previous chart bar's Long confidence < confidence threshold AND the most recent prior signal event is not long or there is no prior signal event
Short: Short confidence >= confidence threshold AND previous chart bar's Short confidence < confidence threshold AND the most recent prior signal event is long