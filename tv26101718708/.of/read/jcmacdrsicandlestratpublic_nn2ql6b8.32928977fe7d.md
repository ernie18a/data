Calculation: Trading window = time limiter disabled OR bar datetime > configured start datetime in the instrument's exchange timezone.
Calculation: Selected-timeframe RSI = RSI of close on the chart timeframe or a configurable higher or lower timeframe. Historical higher-timeframe values use the final value of the bar containing the chart bar, including before that bar completes; lower-timeframe values use the last lower-timeframe bar within the chart bar.
Calculation: Higher-timeframe RSI = RSI of close on a higher timeframe, using the final value of the higher-timeframe bar containing the chart bar, including before that bar completes. Use the same RSI length and thresholds as the selected-timeframe RSI.
Calculation: Body filter = absolute(close - open) / max(high, low) * price scale > body-size threshold.
Calculation: Bullish reversal pin bar = open > high - range * (1 - reversal-wick fraction) AND close > high - range * (1 - reversal-wick fraction) AND low <= lowest low over the reversal lookback including the current bar.
Calculation: Bearish reversal pin bar = open < high - range * reversal-wick fraction AND close < high - range * reversal-wick fraction AND high >= highest high over the reversal lookback including the current bar.
Calculation: Bullish pin bar = body filter AND open > low + range * directional-wick fraction AND close > low + range * directional-wick fraction AND NOT bullish reversal pin bar AND NOT bearish reversal pin bar.
Calculation: Bearish pin bar = body filter AND open < high - range * directional-wick fraction AND close < high - range * directional-wick fraction AND NOT bullish reversal pin bar AND NOT bearish reversal pin bar.
Calculation: Bullish piercing line = body filter AND previous close < previous open AND previous body / previous range >= minimum body fraction AND close > open AND body / range >= minimum body fraction AND open <= previous close AND close < previous open AND close > (previous open + previous close) / 2.
Calculation: Bearish dark cloud cover = body filter AND previous close > previous open AND previous body / previous range >= minimum body fraction AND close < open AND body / range >= minimum body fraction AND open >= previous close AND close > previous open AND close < (previous open + previous close) / 2. Use the same minimum body fraction as the piercing line.
Calculation: Bullish harami = body filter AND previous open > previous close AND close > open AND close <= previous open AND high <= previous open AND current body < previous body AND high < previous high AND low > previous low.
Calculation: Bearish harami = body filter AND previous close > previous open AND open > close AND open <= previous close AND low >= previous open AND current body < previous body AND high < previous high AND low > previous low.
Calculation: Bullish engulfing = body filter AND previous close < previous open AND close > open AND close >= previous high AND open <= previous close.
Calculation: Bearish engulfing = body filter AND previous close > previous open AND close < open AND close <= previous low AND open >= previous close.
Calculation: Top fractal = high two bars ago > highs of the current bar, one, three and four bars ago. Bottom fractal = low two bars ago < lows of the current bar, one, three and four bars ago. The current top or bottom fractal level is the high or low of the latest confirmed corresponding fractal.
Long: Trading window AND selected-timeframe RSI on the previous chart bar < lower threshold AND selected-timeframe RSI > lower threshold.
Short: Trading window AND selected-timeframe RSI on the previous chart bar > upper threshold AND selected-timeframe RSI < upper threshold.
Long: Trading window AND RSI display enabled AND selected-timeframe RSI < lower threshold.
Short: Trading window AND RSI display enabled AND selected-timeframe RSI > upper threshold.
Long: Trading window AND RSI display enabled AND higher-timeframe RSI < lower threshold.
Short: Trading window AND RSI display enabled AND higher-timeframe RSI > upper threshold.
Long: Trading window AND candle display enabled AND bullish pin bar.
Short: Trading window AND candle display enabled AND bearish pin bar.
Long: Trading window AND candle display enabled AND bullish piercing line.
Short: Trading window AND candle display enabled AND bearish dark cloud cover.
Long: Trading window AND candle display enabled AND bullish harami AND NOT bullish piercing line.
Short: Trading window AND candle display enabled AND bearish harami AND NOT bearish dark cloud cover.
Long: Trading window AND candle display enabled AND bullish engulfing.
Short: Trading window AND candle display enabled AND bearish engulfing.
Long: Trading window AND candle display enabled AND body filter AND close > current top fractal level AND previous close <= previous top fractal level AND NOT bullish engulfing AND NOT bullish harami AND close < high - range * shaved-bar fraction.
Short: Trading window AND candle display enabled AND body filter AND close < current bottom fractal level AND previous close >= previous bottom fractal level AND NOT bearish engulfing AND NOT bearish harami AND close > low + range * shaved-bar fraction.
Short: Trading window AND level display enabled AND top fractal.
Long: Trading window AND fractal display enabled AND bottom fractal.
Exit: long, Trading window AND bearish pin bar.
Exit: short, Trading window AND bullish pin bar.
Exit: long, take profit enabled AND high >= entry price + take-profit distance.
Exit: long, stop loss enabled AND low <= entry price - stop-loss distance.
Exit: short, take profit enabled AND low <= entry price - take-profit distance.
Exit: short, stop loss enabled AND high >= entry price + stop-loss distance.
Exit: long, trailing stop enabled AND highest high since entry >= entry price + trailing activation distance AND low <= highest high since activation - trailing offset.
Exit: short, trailing stop enabled AND lowest low since entry <= entry price - trailing activation distance AND high >= lowest low since activation + trailing offset.