Calculation: Channel direction = +1 when hlc3 > ZLEMA(hlc3, channel lookback), otherwise -1
Calculation: T1 channel direction = channel direction calculated on T1 bars using the still-forming T1 bar, with its value mapped to chart bars
Calculation: MACD histogram = MACD histogram(source, fast lookback, slow lookback, signal lookback, oscillator MA type, signal MA type)
Calculation: MACD histogram vote = +1 when (histogram >= 0 AND histogram > histogram[1]) OR (histogram < 0 AND histogram >= histogram[1]); otherwise -1
Calculation: RSI change = RSI(close, RSI lookback) - RSI(close, RSI lookback)[1]
Calculation: RSI change vote = +1 when RSI change > RSI change threshold, -1 when RSI change < -RSI change threshold, otherwise 0
Calculation: Bullish votes = (close >= open ? 1 : 0) + (volume >= volume[1] ? 1 : 0) + (T1 channel direction > 0 ? 1 : 0) + (MACD histogram vote > 0 ? 1 : 0) + (RSI change vote = 1 ? 1 : 0) + (channel direction > 0 ? 1 : 0)
Calculation: Bearish votes = (close < open ? 1 : 0) + (volume < volume[1] ? 1 : 0) + (T1 channel direction < 0 ? 1 : 0) + (MACD histogram vote < 0 ? 1 : 0) + (RSI change vote = -1 ? 1 : 0) + (channel direction < 0 ? 1 : 0)
Calculation: Inconclusive votes = 6 - Bullish votes - Bearish votes
Calculation: Falling trend = count(close[n] <= close[n+1], n from 0 to trend lookback - 1) > count(close[n] > close[n+1], n from 0 to trend lookback - 1)
Calculation: Bullish vote decision = Bullish votes >= 4 OR (Bullish votes = 3 AND Bearish votes = 3 AND RSI change >= 1) OR (Bullish votes >= Bearish votes + Inconclusive votes AND NOT (Bullish votes = 3 AND Bearish votes = 3 AND RSI change < 1) AND NOT (Bullish votes = 3 AND RSI change vote = 0))
Calculation: Bearish vote decision = Bearish votes >= 4 OR (Bullish votes = 3 AND Bearish votes = 3 AND RSI change < 1) OR (Bearish votes >= Bullish votes + Inconclusive votes AND NOT (Bullish votes = 3 AND Bearish votes = 3 AND RSI change >= 1) AND NOT (Bullish votes = 3 AND RSI change vote = 0))
Calculation: Bullish displayed decision = (close != close[1] AND Bullish vote decision) OR (close = close[1] AND close[1] < open[1])
Calculation: Bearish displayed decision = (close != close[1] AND Bearish vote decision) OR (close = close[1] AND close[1] > open[1] AND channel direction[1] > 0)
Calculation: Buy limit price = signal bar close - (signal bar close - signal bar low) * buy offset
Calculation: Sell limit price = if channel direction < 0 AND signal bar close < signal bar open then signal bar close else signal bar close + (signal bar high - signal bar close) * sell offset
Long: channel direction > 0
Short: channel direction < 0
Long: NOT Falling trend
Short: Falling trend
Long: Bullish displayed decision = true
Short: Bearish displayed decision = true
Long: channel direction > 0 AND Bullish displayed decision = true AND ((NOT Falling trend AND max(Bullish votes, Bearish votes) >= 4) OR (Falling trend AND max(Bullish votes, Bearish votes) = 5 AND RSI change != 0)) AND (last trade price = 0 OR abs(close - last trade price) > last trade price * price buffer percentage)
Short: (Bearish displayed decision = true OR Falling trend) AND (last trade price = 0 OR abs(close - last trade price) > last trade price * price buffer percentage)
Long: pending buy limit order AND close <= its stored buy limit price
Long: prior bar met the long setup condition AND current low <= the prior bar's stored buy limit price
Short: prior bar met the short setup condition AND current high >= the prior bar's stored sell limit price
Exit: long, pending sell limit order AND close >= its stored sell limit price