Calculation: EMA_fast, EMA_slow = exponential moving averages of close on the chart timeframe; EMA_fast has a shorter period than EMA_slow.
Calculation: High_long = highest high over a long lookback (about one year of bars) including the current bar.
Calculation: Prior_high = highest high over a short lookback (much shorter than the High_long lookback) of the bars before the current bar, excluding the current bar.
Calculation: RVOL = current bar volume / simple moving average of volume over a recent window including the current bar.
Calculation: StochRSI = RSI of close; Raw = 100*(RSI - lowest RSI over N bars)/(highest RSI over N bars - lowest RSI over N bars), or 0 if highest equals lowest; K = SMA of Raw; D = SMA of K.
Calculation: ATR = average true range on the chart timeframe, current bar.
Long: abs(close - EMA_fast)/close <= small max distance AND close >= High_long*(1 - small max percent) AND close > Prior_high AND RVOL >= threshold AND (EMA_fast crosses above EMA_slow on this bar OR close > EMA_fast) AND StochRSI K > StochRSI D AND StochRSI K < overbought limit AND no position is open
Exit: long, close crosses below EMA_slow (close was >= EMA_slow on the previous bar and < EMA_slow on this bar)
Exit: long, close crosses below EMA_fast (alternative to the EMA_slow exit)
Exit: long, low <= entry price*(1 - stop percent)
Exit: long, high >= entry price*(1 + target percent), which is larger than the stop percent (optional target paired with the percent stop)
Exit: long, low <= entry price - stop multiplier*ATR
Exit: long, high >= entry price + target multiplier*ATR, where the target multiplier is larger than the stop multiplier (optional target paired with the ATR stop)