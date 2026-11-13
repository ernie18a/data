Calculation: EMA fast/mid/slow = exponential moving averages of close, with fast lookback < mid lookback < slow lookback
Calculation: RSI = RSI of close
Calculation: VWAP = session-anchored cumulative sum(typical price (high+low+close)/3 * volume) / cumulative sum(volume), reset each session
Calculation: volume spike = volume > volume simple moving average * multiplier (>1)
Calculation: strong candle = (high-low) > 0 AND abs(close-open)/(high-low) > a body-ratio threshold (about half the range)
Calculation: ATR = average true range at the entry bar
Calculation: long score = count of true among: (1) EMA fast > EMA mid AND EMA mid > EMA slow; (2) RSI > 50 AND RSI < overbought level (overbought level > 50); (3) close > VWAP; (4) volume spike; (5) low > low 2 bars ago AND RSI < RSI 2 bars ago AND RSI < a level slightly above 50; (6) strong candle
Calculation: short score = count of true among: (1) EMA fast < EMA mid AND EMA mid < EMA slow; (2) RSI < 50 AND RSI > oversold level (oversold level < 50); (3) close < VWAP; (4) volume spike; (5) high < high 2 bars ago AND RSI > RSI 2 bars ago AND RSI > a level slightly below 50; (6) strong candle
Long: long score >= min score threshold AND long score > long score of previous bar AND number of bars since the last bar on which this Long condition fired > 3
Short: short score >= min score threshold AND short score > short score of previous bar AND number of bars since the last bar on which this Short condition fired > 3
Exit: long, close <= entry price - ATR * stop multiplier OR close >= entry price + ATR * take-profit multiplier (take-profit multiplier > stop multiplier)
Exit: short, close >= entry price + ATR * stop multiplier OR close <= entry price - ATR * take-profit multiplier (take-profit multiplier > stop multiplier)