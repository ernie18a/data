Calculation: VWAP = session VWAP of (high+low+close)/3
Calculation: VWAPStdDev = sqrt(cumsum(((high+low+close)/3 - VWAP)^2 * volume) / cumsum(volume)), cumsum running from the first bar
Calculation: GaussianFilter = Gaussian filter((high+low+close)/3, Gaussian period, Gaussian poles)
Calculation: MACDHist = MACD histogram(close, shorter lookback, longer lookback, signal lookback)
Calculation: RSIValue = RSI(close, RSI lookback)
Calculation: VolumeSpike = volume >= SMA(volume, volume lookback) * volume spike multiplier
Calculation: OpeningRangeHigh = highest high of regular-session bars within the first opening range length minutes after regular session open, in the same T1 period as the current bar
Calculation: OpeningRangeLow = lowest low of regular-session bars within the first opening range length minutes after regular session open, in the same T1 period as the current bar
Calculation: LongTrigger = close crosses above EMA(close, shortest lookback) OR close crosses above VWAP OR (close crosses above OpeningRangeHigh AND bar time in regular session and at least opening range length minutes after regular session open)
Calculation: ShortTrigger = close crosses below EMA(close, shortest lookback) OR close crosses below VWAP OR (close crosses below OpeningRangeLow AND bar time in regular session and at least opening range length minutes after regular session open)
Calculation: LongScore = count of true among: EMA(close, shortest lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longest lookback); close > VWAP; close > GaussianFilter AND GaussianFilter > GaussianFilter[1]; MACDHist > 0 AND MACDHist > MACDHist[1]; RSIValue > RSI midline AND RSIValue < RSI overbought level; VolumeSpike; LongTrigger
Calculation: ShortScore = count of true among: EMA(close, shortest lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longest lookback); close < VWAP; close < GaussianFilter AND GaussianFilter <= GaussianFilter[1]; MACDHist < 0 AND MACDHist < MACDHist[1]; RSIValue < RSI midline AND RSIValue > RSI oversold level; VolumeSpike; ShortTrigger
Calculation: BarsSinceSignal = bars elapsed since the most recent earlier bar on which a Long or Short condition was true
Long: LongScore >= minimum confluence score AND LongTrigger AND bar time in session window AND bar time not in lunch window AND BarsSinceSignal >= cooldown bars
Short: ShortScore >= minimum confluence score AND ShortTrigger AND bar time in session window AND bar time not in lunch window AND BarsSinceSignal >= cooldown bars
Long: low <= VWAP - band multiplier * VWAPStdDev AND RSIValue <= RSI oversold level AND close > open AND bar time in session window AND bar time not in lunch window AND BarsSinceSignal >= cooldown bars
Short: high >= VWAP + band multiplier * VWAPStdDev AND RSIValue >= RSI overbought level AND close < open AND bar time in session window AND bar time not in lunch window AND BarsSinceSignal >= cooldown bars
Option: buy call, LongScore >= minimum confluence score AND LongTrigger AND bar time in session window AND bar time not in lunch window AND BarsSinceSignal >= cooldown bars
Option: buy put, ShortScore >= minimum confluence score AND ShortTrigger AND bar time in session window AND bar time not in lunch window AND BarsSinceSignal >= cooldown bars