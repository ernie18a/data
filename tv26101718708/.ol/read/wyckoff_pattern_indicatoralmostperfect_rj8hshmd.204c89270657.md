Calculation: Average volume = simple moving average of volume over the shared phase lookback
Calculation: High volume = volume > average volume × volume-climax multiplier
Calculation: Low volume = volume < average volume × 0.55
Calculation: Long-term trend = longer-period EMA(close) > still-longer-period EMA(close)
Calculation: Short-term trend = shorter-period EMA(close) > medium-period EMA(close)
Calculation: RSI = relative strength index of close
Calculation: MACD histogram = difference between the MACD line and its signal line; MACD line is the shorter-period EMA(close) minus the longer-period EMA(close), and the signal line is an EMA of the MACD line
Calculation: ATR = average true range
Calculation: Range high/low = highest high / lowest low over the shared phase lookback
Calculation: Price position = (close − range low) / max(range high − range low, ATR × 0.01)
Calculation: Relative volatility = standard deviation of close over a shorter lookback / simple moving average of close over that same lookback
Calculation: In range = relative volatility < its simple moving average over the phase lookback × 0.85
Calculation: Accumulation score = 2 if price position < 0.35, plus 1 if long-term trend is false, plus 2 if in range, plus 1 if low volume and in range, plus 1 if RSI < 50, plus 1 if MACD histogram > its value three bars earlier
Calculation: Distribution score = 2 if price position > 0.65, plus 1 if long-term trend is true, plus 2 if in range, plus 1 if low volume and in range, plus 1 if RSI > 50, plus 1 if MACD histogram < its value three bars earlier
Calculation: Raw accumulation = accumulation score >= 5 and accumulation score > distribution score
Calculation: Raw distribution = distribution score >= 5 and distribution score > accumulation score
Calculation: Accumulation state = raw accumulation has held for at least 3 consecutive bars; reset the count when raw accumulation is false
Calculation: Distribution state = raw distribution has held for at least 3 consecutive bars; reset the count when raw distribution is false
Calculation: Accumulation phase = reset to 0 when accumulation state is false; otherwise advance from 0 to 1, from 1 to 2 when in range, from 2 to 3 on a spring, from 3 to 4 on a sign of strength, and from 4 to 5 when short-term trend is true and not in range
Calculation: Distribution phase = reset to 0 when distribution state is false; otherwise advance from 0 to 1, from 1 to 2 when in range, from 2 to 3 on an upthrust after distribution, from 3 to 4 on a sign of weakness, and from 4 to 5 when short-term trend is false and not in range
Calculation: Selling climax = close < open AND high volume AND (high − close) / max(high − low, 0.0001) > 0.6 AND close <= range low × 1.002
Calculation: Buying climax = close > open AND high volume AND (close − low) / max(high − low, 0.0001) > 0.6 AND close >= range high × 0.998
Calculation: Spring = close > open AND low < lowest low over a shorter lookback on the previous bar AND close > that previous-bar lowest low AND volume > simple moving average of volume over a shorter lookback
Calculation: Upthrust after distribution = close < open AND high > highest high over a shorter lookback on the previous bar AND close < that previous-bar highest high AND volume > simple moving average of volume over a shorter lookback
Calculation: Sign of strength = close > open AND close > highest close over a shorter lookback on the previous bar AND volume > simple moving average of volume over that same lookback AND MACD histogram > 0
Calculation: Sign of weakness = close < open AND close < lowest close over a shorter lookback on the previous bar AND volume > simple moving average of volume over that same lookback AND MACD histogram < 0
Calculation: Last point of support = close > open AND NOT high volume AND short-term trend AND price position > 0.4
Calculation: Last point of supply = close < open AND NOT high volume AND NOT short-term trend AND price position < 0.6
Calculation: Raw buy signal = NOT distribution state AND ((accumulation state AND accumulation phase is 3 or 4) OR (spring AND NOT distribution state) OR (last point of support AND accumulation state))
Calculation: Raw sell signal = NOT accumulation state AND ((distribution state AND distribution phase is 3 or 4) OR (upthrust after distribution AND NOT accumulation state) OR (last point of supply AND distribution state))
Calculation: Buy signal = raw buy signal AND previous signal state is not buy; signal state is buy when raw buy is true, otherwise sell when raw sell is true, otherwise hold when neither is true and (in range OR accumulation phase is 2 while in accumulation OR distribution phase is 2 while in distribution), otherwise none; update previous signal state to the current non-none state, or none
Long: Selling climax OR spring AND NOT distribution state OR sign of strength OR last point of support AND accumulation state OR buy signal
Short: Buying climax OR upthrust after distribution AND NOT accumulation state OR sign of weakness OR last point of supply AND distribution state OR raw sell signal AND previous signal state is not sell