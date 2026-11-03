Calculation: VWAP = volume-weighted average price of (high + low + close) / 3
Calculation: Upper/lower band = VWAP +/- band multiplier * rolling standard deviation of (HLC3 - VWAP)
Calculation: Bullish pattern = bullish engulfing OR bullish harami OR hammer OR inverted hammer OR morning star OR piercing line OR bullish REB OR bullish sweep OR bullish body dominance
Calculation: Bearish pattern = bearish engulfing OR bearish harami OR hanging man OR shooting star OR evening star OR dark cloud OR bearish REB OR bearish sweep OR bearish body dominance
Calculation: Bullish engulfing = previous candle bearish AND current candle bullish AND current open <= previous close AND current close > previous open AND current body > 1.1 * previous body AND previous close < previous moving average
Calculation: Bearish engulfing = previous candle bullish AND current candle bearish AND current open >= previous close AND current close < previous open AND current body > 1.1 * previous body AND previous close > previous moving average
Calculation: Bullish harami = previous candle bearish AND current candle bullish AND current open > previous close AND current close < previous open AND current body < 0.5 * previous body AND previous body is at least the long-candle thresholds for body/close, body/range, and body/ATR AND previous close < previous moving average
Calculation: Bearish harami = previous candle bullish AND current candle bearish AND current open < previous close AND current close > previous open AND current body < 0.5 * previous body AND previous body is at least the long-candle thresholds for body/close, body/range, and body/ATR AND previous close > previous moving average
Calculation: Hammer shape = lower shadow > 2 * body AND upper shadow < 0.2 * range AND range > 0.3 * ATR AND body > 0
Calculation: Inverted hammer shape = upper shadow > 2 * body AND lower shadow < 0.2 * range AND range > 0.3 * ATR AND body > 0
Calculation: Hammer = hammer shape AND current close < current moving average
Calculation: Hanging man = hammer shape AND current close > current moving average
Calculation: Inverted hammer = inverted hammer shape AND current close < current moving average
Calculation: Shooting star = inverted hammer shape AND current close > current moving average
Calculation: Morning star = candle two bars ago bearish AND its body > its ATR AND middle candle body/range <= short-candle threshold AND middle close < close two bars ago AND current candle bullish AND current close > middle close AND close two bars ago < its moving average
Calculation: Evening star = candle two bars ago bullish AND its body > its ATR AND middle candle body/range <= short-candle threshold AND middle close > close two bars ago AND current candle bearish AND current close < middle close AND close two bars ago > its moving average
Calculation: Piercing line = previous candle bearish AND previous body > 0.8 * previous ATR AND current candle bullish AND current open < previous close AND current close > previous body midpoint AND current close < previous open AND previous close < previous moving average
Calculation: Dark cloud = previous candle bullish AND previous body > 0.8 * previous ATR AND current candle bearish AND current open > previous close AND current close < previous body midpoint AND current close > previous open AND previous close > previous moving average
Calculation: Bullish REB = current range > 1.5 * average range over a longer lookback AND current candle bullish AND current close >= current high - current range / 3 AND current close > current moving average
Calculation: Bearish REB = current range > 1.5 * average range over a longer lookback AND current candle bearish AND current close <= current low + current range / 3 AND current close < current moving average
Calculation: Bullish sweep = current low < lowest low of the preceding shorter lookback AND current close > that low AND current candle bullish AND current close < current moving average
Calculation: Bearish sweep = current high > highest high of the preceding shorter lookback AND current close < that high AND current candle bearish AND current close > current moving average
Calculation: Bullish body dominance = current candle bullish AND body/range >= body-dominance threshold
Calculation: Bearish body dominance = current candle bearish AND body/range >= body-dominance threshold
Long: previous close was within the VWAP bands AND current close is outside either band AND current close > current moving average AND bullish pattern
Short: previous close was within the VWAP bands AND current close is outside either band AND current close < current moving average AND bearish pattern