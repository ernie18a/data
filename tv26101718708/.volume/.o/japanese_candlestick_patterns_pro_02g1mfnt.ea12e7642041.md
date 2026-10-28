Calculation: Candle body = abs(close - open)
Calculation: Candle range = high - low
Calculation: Upper shadow = high - max(open, close)
Calculation: Lower shadow = min(open, close) - low
Calculation: Body midpoint = (open + close) / 2
Calculation: Average body = simple moving average of candle body
Calculation: Long candle = body / close * 100 >= threshold AND body / range * 100 >= threshold AND body / average body * 100 >= threshold
Calculation: Short candle = body / range * 100 <= threshold
Calculation: High volume = volume > simple moving average of volume over a shorter lookback * threshold
Calculation: Downtrend = close < selected simple or exponential moving average
Calculation: Uptrend = close > selected simple or exponential moving average
Calculation: Hammer-shaped = lower shadow > body * threshold AND upper shadow < range * 0.2 AND range > average body * 0.3 AND body > 0
Calculation: Inverted-hammer-shaped = upper shadow > body * threshold AND lower shadow < range * 0.2 AND range > average body * 0.3 AND body > 0
Calculation: Bullish engulfing = previous candle bearish AND current candle bullish AND current open <= previous close AND current close > previous open AND current body > previous body * 1.1 AND (trend filter disabled OR previous candle downtrend) AND (volume filter disabled OR current volume is high)
Calculation: Bearish engulfing = previous candle bullish AND current candle bearish AND current open >= previous close AND current close < previous open AND current body > previous body * 1.1 AND (trend filter disabled OR previous candle uptrend) AND (volume filter disabled OR current volume is high)
Calculation: Bullish harami = previous candle bearish AND current candle bullish AND current open > previous close AND current close < previous open AND current body < previous body * 0.5 AND previous candle is long AND (trend filter disabled OR previous candle downtrend)
Calculation: Bearish harami = previous candle bullish AND current candle bearish AND current open < previous close AND current close > previous open AND current body < previous body * 0.5 AND previous candle is long AND (trend filter disabled OR previous candle uptrend)
Calculation: Hammer = current candle is hammer-shaped AND (trend filter disabled OR current candle downtrend)
Calculation: Hanging man = current candle is hammer-shaped AND (trend filter disabled OR current candle uptrend)
Calculation: Inverted hammer = current candle is inverted-hammer-shaped AND (trend filter disabled OR current candle downtrend)
Calculation: Shooting star = current candle is inverted-hammer-shaped AND (trend filter disabled OR current candle uptrend)
Calculation: Morning star = candle two bars ago bearish AND its body > current average body AND previous candle is short AND previous close < close two bars ago AND current candle bullish AND current close > previous close AND (trend filter disabled OR candle two bars ago downtrend)
Calculation: Evening star = candle two bars ago bullish AND its body > current average body AND previous candle is short AND previous close > close two bars ago AND current candle bearish AND current close < previous close AND (trend filter disabled OR candle two bars ago uptrend)
Calculation: Piercing line = previous candle bearish AND previous body > current average body * 0.8 AND current candle bullish AND current open < previous close AND current close > previous body midpoint AND current close < previous open AND (trend filter disabled OR previous candle downtrend)
Calculation: Dark cloud = previous candle bullish AND previous body > current average body * 0.8 AND current candle bearish AND current open > previous close AND current close < previous body midpoint AND current close > previous open AND (trend filter disabled OR previous candle uptrend)
Calculation: Three white soldiers = current and previous two candles bullish AND current close > previous close > close two bars ago AND current open > previous open > open two bars ago AND current open < previous close AND previous open < close two bars ago AND each of the three bodies > current average body * 0.6 AND (trend filter disabled OR candle two bars ago downtrend)
Calculation: Three black crows = current and previous two candles bearish AND current close < previous close < close two bars ago AND current open < previous open < open two bars ago AND current open > previous close AND previous open > close two bars ago AND each of the three bodies > current average body * 0.6 AND (trend filter disabled OR candle two bars ago uptrend)
Calculation: Three inside up = candle two bars ago bearish and long AND previous candle bullish AND previous high < high two bars ago AND previous low > low two bars ago AND previous open > close two bars ago AND previous close < open two bars ago AND current candle bullish AND current close > high two bars ago AND (trend filter disabled OR candle two bars ago downtrend)
Calculation: Three inside down = candle two bars ago bullish and long AND previous candle bearish AND previous high < high two bars ago AND previous low > low two bars ago AND previous open < close two bars ago AND previous close > open two bars ago AND current candle bearish AND current close < low two bars ago AND (trend filter disabled OR candle two bars ago uptrend)
Calculation: Three outside up = candle two bars ago bearish AND previous candle bullish AND previous open < close two bars ago AND previous close > open two bars ago AND previous high > high two bars ago AND previous low < low two bars ago AND current candle bullish AND current close > previous close AND (trend filter disabled OR candle two bars ago downtrend)
Calculation: Three outside down = candle two bars ago bullish AND previous candle bearish AND previous open > close two bars ago AND previous close < open two bars ago AND previous high > high two bars ago AND previous low < low two bars ago AND current candle bearish AND current close < previous close AND (trend filter disabled OR candle two bars ago uptrend)
Long: bullish engulfing OR bullish harami OR hammer OR inverted hammer OR morning star OR piercing line OR three white soldiers OR three inside up OR three outside up
Short: bearish engulfing OR bearish harami OR hanging man OR shooting star OR evening star OR dark cloud OR three black crows OR three inside down OR three outside down